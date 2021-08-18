# Credential free provisioning with Terraform Cloud Agent on AWS ECS

This repository provides an example of using TFCB to manage multiple [tfc-agent](https://hub.docker.com/r/hashicorp/tfc-agent) pools each tied to their own ECS fargate service within the same ECS cluster.  This is intended for larger environments that need to issolate provisioning tasks and permissions across teams in a scalable way.   To best understand using TFCB and agents for credential free provisioning please refer to the original [tfc-agent-ecs guide](https://github.com/assareh/tfc-agent/tree/master/tfc-agent-ecs).  In this guide you will use workspaces to isolate the roles and responsibilities for each team (IAM, Ops, and Services).  For efficient administration of these TFCB workspaces you will leverage the Terraform TFE provider to build and manage these workspaces using IaC.

## TFCB Workspaces Overview
1. `Admin-TFE-Workspace`: This workspace (ws) will be used as a centralized admin ws that contains all sensitive or standard inputs and should only be accessible by TFCB owners.  You can use this to initially provision child ws with encrypted variables and other standard configs.
2. `aws_iam`: This ws will manage sensitive data like IAM permissions, roles, and TFCB tokens. This ws can be owned by your IAM or security team. You will provision your service roles here and enable ECS to assume the correct service role and only run tasks with that service's permissions.  To do this the ws will create an agent pool per service.  Each service will have its own agent_pool, token, and AWS SSM param containing the token allowing you to fully isolate runs from other services. This is the first ws to update when onboarding a new service.
3. `aws_ecs_tfcagents`:  This is the ECS cluster that will isolate every service's TFCB runs by creating an ECS service per service team that runs with the team's IAM role.  This ws may be owned by the Shared Services or Platform team. It requires access to the aws_iam ws outputs to read the service teams IAM role needed to configure ECS.
4. `aws_serviceA, aws_serviceB`: These are example ws that would be operated by each of your service teams.  These workspaces have no credentials and rely on assume_role to access AWS and provision resources their role was granted access too.  This allows your IAM team to manage all service team permissions without needing to manage or deploy credentials.
5. `Admin-Sentinel-Policies`: This ws will allow you to use Sentinel (policy as code) to enforce the proper role is used by each service team.  This prevents the chance a service team uses an elivated role, or accidently provisions infrastructure in the wrong AWS account.

## Prerequisites
* [Terraform Cloud Business Tier](https://www.hashicorp.com/blog/announcing-hashicorp-terraform-cloud-business) to run Agents
* AWS Credentials to provision infrastructure (assume_role, EC2)

## TFCB Setup
1. First fork this repo in your github.com account and clone it locally.
```
cd <your_working_project_dir>  # this is your project base dir. It can by any dir you want.
git clone <your_git_URL>
cd tfc-agents
cd ./tfc-agent-ecs-multi/files/create_tfcb_workspaces
cd ./tfc-agent-ecs-multi/files/create_tfcb_workspaces/scripts
```
1. Read `TFE_Workspace_README.md` and follow the setup steps to create your admin workspace.  When creating your admin workspace source your AWS Credentials into your shell env to have them added to your admin workspace.  The child workspaces we are about to create for IAM and ECS components can easily pull these as encrypted values at setup time to save you the trouble of inputing them manually.

2. Once your admin workspace is created it should be linked to this repo and have a working directory `tfc-agent-ecs-multi/files/create_tfcb_workspaces` set that points to sample IaC that will manage all your workspaces. Copy the latest workspace IaC into this base directory to get started.
```
cd tfc-agent-ecs-multi/files/create_tfcb_workspaces
cp -rf core_workspaces/* .
```
Use the UI to review the current config and then manually trigger a terraform plan and apply in the new admin workspace you created. Go to the workspace `Actions -> Start plan now`.  You should see new workspaces created `aws_iam, aws_agent_ecs`.
   * If you want your child workspaces to inherit AWS creds from the admin workspace uncomment the following lines in both files (`ws_aws_ecs_tfcagents.tf, ws_aws_iam.tf`)
      ```
      #aws_secret_access_key = "${var.aws_secret_access_key}"
      #aws_access_key_id = "${var.aws_access_key_id}"
      ```
   If you already ran the admin workspace thats fine.  Just run it again to pick up these changes to your IaC.  If using another tool (ie: doormat) to manage credentials then keep these commented.

1. Now run an apply in `ws_aws_iam` to create all your service teams IAM roles and policies.  This workspace is also responsible for creating tfc_agent pools, and tokens per service. It will push each token into an SSM param store owned by the service. The ECS task will be able to securely pull the right service token at runtime ensuring services are each using their agent_pool and have complete isolation.

2. Next go to Settings -> General -> and review the Share state globally that we enabled.  This will allow `ws_aws_agent_ecs` and your ADMIN workspace to have access to the IAM workspace outputs they need to properly setup and run tasks with the proper roles.
   * For better security you should update this to only allow specific workspaces versus sharing state globally.
   * We put all service IAM roles into one workspace in this example.  In large environments this workspace could be broken into smaller workspaces for each AWS account, or service for more granular security.  Alternatively, you can keep all IAM configs in 1 workspace and create child workspaces to manage outputs that each service/team can access.

3. Next run an apply in `ws_aws_agent_ecs` to create your ECS cluster which requires  access to the ws_aws_iam state file for its IAM policies.

4. Now that you have the IAM and ECS services built you are ready to build workspaces for the individual service teams to use.  Each team will have access to their own workspace and the IAM role that was created for them by the IAM workspace/team.

   Copy the service workspace creation code into the working directory and commit it.
   ```
   cd ./tfc-agent-ecs-multi/files/create-tfcb-workspaces
   cp ./add_service_workspaces/* .
   git add .
   git commit -m "Adding serviceA, serviceB workspaces"
   git push
   ```
   Your admin workspace should pick up this change and automatically create your service workspaces `ws_aws_serviceA, ws_aws_serviceB`.  Verify thse workspaces have been created in the UI and look at their configuration.  These workspaces are a little different from our main services.  They are using the [Agent Execution Mode](https://www.terraform.io/docs/cloud/workspaces/settings.html#execution-mode).  Look at the variables in these workspaces and verify they were created with no AWS credentials.  These workspaces will be leveraging the IAM roles previously built for them by using assume_role in their terraform code.

5. Test each service workstation roles are working by running a job.  They are pre-configured with IaC to build an EC2 instance.  While they are running a plan check out the agent pools in the UI.  Go to [ Settings -> Agents ] and you should see two pools configured for your 2 services.  Each pool has 2 agents configured and one should be busy running your job.

## Optional - Enforce Sentinel Policies
Now that you have everything working lets use Sentinel to enforce governance.  For this use case you want to ensure each service is only able to use their own IAM role.  ServiceA should not be able to use ServiceB's role.  
1.  To add Sentinel policies as code to our workflow we will want to [fork the existing terraform-guides public repo](https://github.com/hashicorp/terraform-guides) under our own personal repo. terraform-guides includes 100's of working sentinel examples.  Click on `Fork`, and chose your organization/repo.
2.  Now that you have terraform-guides forked into your repo lets clone it so we can pull the code locally to customize a couple AWS sentinel policies.  Click on `Code` and then the copy icon to get your full <git URL>.
```
cd <your_working_project_dir>
git clone <git URL>
cp tfc-agent/tfc-agent-ecs-multi/files/sentinel_policy_set/* terraform-guides/governance/third-generation/aws/
git add .
git commit -m "adding my aws assume role policies"
git push
```
Review `./tfc-agent/tfc-agent-ecs-multi/files/sentinel_policy_set` to see the policies.  One assumed roles policy is verifying the workspace to role names with a regex to ensure 1/1 mapping.

1. You should have a policy repo now with your defined policies.  Next, build the TFCB Sentinel workspace that will link to this repo and automatically apply the policies after changes.  Review your ADMIN workspace variables so you know what is available to your child workspaces and verify the tf_variables or correct in this file:

`./add_sentinel_workspace/ws_ADMIN_Sentinel_Policies.tf`
```
cd ./tfc-agent/tfc-agent-ecs-multi/files/create_tfcb_workspaces/
cp -rf ./add_sentinel_workspace/* ../
git add .
git commit -m "add sentinel ws and policy_set"
git push
```
This commit should trigger a run on your ADMIN workspace.  The new files you added will create a policy_set and a new workspace that will push out the latest policy updates anytime there are changes to the policies in the terraform-guides repo you forked.  Now you should have a Sentinel policy set defined in TFCB and mapped to service_A and service_B workspaces.

4. To test your policies are working, go into service_A workspace , click on variables, and edit `dev_role_arn`.  The existing value should look something like...
```
arn:aws:iam::112233445566:role/iam-role-serviceA
```

Update this to use the service_B role instead
```
arn:aws:iam::112233445566:role/iam-role-serviceB
```
Save the variable update and run a new plan/apply from the UI.  You should see that policy checks have been added to your workflow and it will have a soft failure because the role name being assumed does not match the workspace name regex we are using.

## Notes

## Additional Topics
* A [Sentinel](https://www.terraform.io/docs/cloud/sentinel/index.html) policy like [this example](https://github.com/hashicorp/terraform-guides/blob/master/governance/third-generation/aws/restrict-assumed-roles-by-workspace.sentinel) can be used to restrict which roles would be allowed in a given workspace.
* Terraform code and policies to support IAM roles and workspaces for example service-A and service-B are in `/files`.


## References
* [Terraform Cloud Agent Docs](https://www.terraform.io/docs/cloud/workspaces/agent.html)
* [Agent Pools and Agents API](https://www.terraform.io/docs/cloud/api/agents.html)
* [Agent Tokens API](https://www.terraform.io/docs/cloud/api/agent-tokens.html)