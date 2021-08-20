# Credential free provisioning with Terraform Cloud Agent on AWS ECS

This demo uses TFCB through multiple [tfc-agent](https://hub.docker.com/r/hashicorp/tfc-agent) pools each tied to their own AWS ECS fargate service.  This is intended for larger environments that need to issolate provisioning tasks across various teams or AWS accounts in a scalable way.   To best understand using TFCB and agents for credential free provisioning please refer to the original [tfc-agent-ecs guide](https://github.com/assareh/tfc-agent/tree/master/tfc-agent-ecs).  In this demo you will use multiple workspaces to isolate the various roles and responsibilities across the following teams (IAM, Ops, Governance, and Service teams A & B).  For efficient administration of these TFCB workspaces you will leverage the Terraform TFE provider to build and manage them using IaC.

## TFCB Workspaces Overview
Lets take a quick look at how we are breaking up our workspaces or IaC.

1. `admin_ws_agentdemo`: This workspace (ws) will be used as a centralized admin ws that contains all sensitive or standard inputs and should only be accessible by TFCB owners.  You can use this to initially provision child ws with encrypted variables and other standard configs.
2. `aws_iam`: This ws will manage sensitive data like IAM permissions, roles, and TFCB tokens. This ws can be owned by your IAM or security team. You will provision your service roles here and enable ECS to assume the correct service role and only run tasks with that service's permissions.  To do this the ws will create an agent pool per service.  Each service will have its own agent_pool, token, and AWS SSM param containing the token allowing you to fully isolate runs from other services. This is the first ws to update when onboarding a new service.
3. `aws_ecs_tfcagents`:  This is the ECS cluster that will isolate every service's TFCB runs by creating an ECS service per service team that runs with the team's IAM role.  This ws may be owned by the Shared Services or Platform team. It requires access to the aws_iam ws outputs to read the service teams IAM role needed to configure ECS.
4. `aws_serviceA, aws_serviceB`: These are example ws that would be operated by each of your service teams.  These workspaces have no credentials and rely on assume_role to access AWS and provision resources their role was granted access too.  This allows your IAM team to manage all service team permissions without needing to manage or deploy credentials.
5. `Admin-Sentinel-Policies`: This ws will allow you to use Sentinel (policy as code) to enforce the proper role is used by each service team.  This prevents the chance a service team uses an elivated role, or accidently provisions infrastructure in the wrong AWS account.

## Prerequisites
* [Terraform Cloud Business Tier](https://www.hashicorp.com/blog/announcing-hashicorp-terraform-cloud-business) to run Agents
* AWS Credentials to provision infrastructure (assume_role, EC2)

## Setup

### TFCB Setup Admin Workspace
1. First fork this repo in your github.com account and clone it locally.
```
cd <your_working_project_dir>  # this is your project base dir. It can by any dir you want.
git clone <your_git_URL>
cd tfc-agents/tfc-agent-ecs-multi/files/create_tfcb_workspaces/scripts
```
2. Read `TFE_Workspace_README.md` and follow the setup steps to create your admin workspace.  

   When creating your admin workspace source your AWS Credentials into your shell env to have them automatically added to your admin workspace.  The child workspaces we are about to create for IAM and ECS components can easily pull these as encrypted values at setup time to save you the trouble of inputing them manually.
```
$  ./addAdmin_workspace.sh
Using Github repo: https://github.com/ppresto/tfc-agent.git
Using workspace name:  admin_ws_agentdemo
Checking to see if workspace exists
Traceback (most recent call last):
  File "<string>", line 1, in <module>
KeyError: 'data'
Workspace ID:
Workspace did not already exist; will create it.
Checking Workspace Result: {"data":{"id":"ws-LtXVexbrUyDP6bBj","type":"workspaces"
...

Workspace ID:  ws-LtXVexbrUyDP6bBj
Adding CONFIRM_DESTROY
Adding OAUTH_TOKEN_ID
Adding ATLAS_TOKEN
Adding organization
Adding Github org ppresto
Adding AWS_ACCESS_KEY_ID
Adding AWS_SECRET_ACCESS_KEY
Adding AWS_DEFAULT_REGION
Number of Sentinel policies:  0
Finished
```
Login to TFCB and you should see the admin workspace you just created (default: `admin_ws_agentdemo`)

3. Once your admin workspace is created it should be linked to your forked repo and configured with this working directory `tfc-agent-ecs-multi/files/create_tfcb_workspaces` pointing to sample IaC that will manage all your workspaces. The core workspace IaC is in the base directory to get you started.  Review the *.tf files and optionally update the 'prefix' value to something unique to help idenitfy your demo resources.  We are leveraging this same repo with a working directory to make the setup easier, but ideally in a real env this would live in its own repo.
```
cd ..
git status
# if you made changes then add, commit, and push.  otherwise skip these steps.
git add .
git commit -m "getting started with core services for IAM and ECS"
git push

```
Use the UI to review the current config and then manually trigger a terraform plan and apply in the new admin workspace you created. Go to the workspace `Actions -> Start new plan now`.  Enter an optional description like "init" and see two new workspaces `aws_iam, aws_agent_ecs` created.
   * If you want your child workspaces to inherit AWS creds from the admin workspace uncomment the following lines in these files (`ws_aws_ecs_tfcagents.tf, ws_aws_iam.tf`)
      ```
      #aws_secret_access_key = "${var.aws_secret_access_key}"
      #aws_access_key_id = "${var.aws_access_key_id}"
      ```
   If you already ran the admin workspace thats fine.  Just run it again to pick up these changes to your IaC.  If using another tool (ie: doormat) to manage credentials then keep these commented.

### TFCB Setup Core IAM and ECS Dependencies
1. Click on `aws_iam` workspace -> Actions -> Start new plan.  This will create all your service teams IAM roles and policies.  This workspace is also responsible for creating tfc_agent pools, and tokens per service. It will push each token into an SSM param store owned by the service. The ECS task will be able to securely pull the right service token at runtime ensuring services are each using their agent_pool and have complete isolation.

2. Review Settings -> General -> Share state globally.  This will allow `aws_agent_ecs` and your ADMIN workspace to have access to the IAM roles they need to properly setup and run ECS tasks.
   * For better security you should update this to only allow specific workspaces versus sharing state globally.
   * We put all service IAM roles into one workspace in this example.  In large environments this workspace could be broken into smaller workspaces for each AWS account, or service for more granular security.  Alternatively, you can keep all IAM configs in 1 workspace and create child workspaces to manage outputs that each service/team can access.

3. Click on `aws_agent_ecs` workspace -> Actions -> Start new plan to create your ECS cluster which is running as a shared service in this env.  It is configured with two services (serviceA, serviceB).  If desired, additional automation defining these services could be done using terraform templates for scale. `aws_agent_ecs` relies on reading the `aws_iam` workspace state file to securely pull serviceA and serviceB proper IAM role, and SSM param store containing the agent_pool token.

### TFCB Setup service teams consuming TFCB (ServiceA, ServiceB)
Now that you have the core IAM roles and ECS services built you are ready to give the individual service teams their own workspaces they can use to provision infra.  Each team will have access to their own workspace and the IAM role that was created for them by the IAM workspace `aws_iam`.

1. Copy the service workspace creation code into the working directory and commit it.
   ```
   cp ./add_service_workspaces/ws_aws_all_services.tf .
   git add .
   git commit -m "Adding serviceA, serviceB workspaces"
   git push
   ```
   Your admin workspace should pick up this change and automatically create your service workspaces `ws_aws_serviceA, ws_aws_serviceB`.  Verify these workspaces have been created in the UI and look at their configuration.  These workspaces are a little different from our main services.  They are using the [Agent Execution Mode](https://www.terraform.io/docs/cloud/workspaces/settings.html#execution-mode).  Look at the variables in these workspaces and verify they were created with no AWS credentials.  These workspaces will be leveraging the IAM roles previously built for them by using assume_role in their terraform code.

2. Test `ws_aws_serviceB` workstation roles are working by running a plan now.  They are pre-configured with IaC to build an EC2 instance.  While they are running a plan check out the agent pools in the UI.  Go to [ Settings -> Agents ] and you should see two pools configured for your 2 services.  Each pool has 2 agents configured and one should be busy running the current plan.

#### ServiceA
AWS access is obtained through the tfc-agent. In this use case the AWS ECS task is defined with the IAM role and using a custom tfc-agent container that is sourcing the roles AWS credentials into the runtime environment for terraform to use.  A Terraform user does not need to provide any aws credentials or use assume_role in their terraform code.  In fact, they never need to see the IAM role being used here.
```
provider "aws" {
  region = "us-west-2"
}
```
The AWS provider now supports making the AWS role credentials available to ECS tasks by default but its a good base example to work from so I kept it. Customizing the tfc-agents container image can be helpful for customization auth, secrets mgmt, and other runtime environment requirements for 3rd party integrations.  You can review it here `./tfc-agent-ecs-multi/files/docker`

#### ServiceB
AWS access is obtained through the tfc-agent using assume_role. The AWS ECS task running the tfc-agent is granted IAM permissions to assume roles for all the different service teams. When the agent runs the terraform code is configured by the service team with the role to assume.  This is invoked in the aws provider as follows:
```
provider "aws" {
  assume_role {
    role_arn     = var.dev_role_arn
    session_name = "terraform"
  }
...
```
This model gives the service team more visibility into the IAM role and requires them to provide this in their IaC.  This can be very helpful for the backend shared service to support multi-tenant workloads without complex configuration.  To ensure service teams are using the proper roles in this model we can leverage Seninel policies.


## Enforce Sentinel Policies on assume_role
Now that you have everything working lets use Sentinel to enforce governance.  For this use case you want to ensure each service is only able to use their own IAM role.  ServiceA should not be able to use ServiceB's role.  
1.  To add Sentinel policies as code to our workflow we will want to [fork the existing terraform-guides public repo](https://github.com/hashicorp/terraform-guides) under our own personal repo. terraform-guides includes 100's of working sentinel examples.  Click on `Fork`, and chose your organization/repo.
2.  Now that you have terraform-guides forked into your repo lets clone it so we can pull the code locally to customize a couple AWS sentinel policies.  Click on `Code` and then the copy icon to get your full <git URL>.
```
cd /<your_working_project_dir>
git clone <git URL>
cp tfc-agent/tfc-agent-ecs-multi/files/sentinel_policy_set/* terraform-guides/governance/third-generation/aws/
cd terraform-guides
git add .
git commit -m "adding my aws assume role policies"
git push
```
Review `./tfc-agent/tfc-agent-ecs-multi/files/sentinel_policy_set/*.sentinel` to read the policies.  The assumed_role policy is verifying the workspace name matches the role name using a regex to ensure 1/1 mapping and other service teams are trying to assume the wrong roles.

1. You should have a policy repo now with your defined policies.  In some cases a different team will want to manage security policy so build the `admin_sentinel_policies` workspace for this purpose. It that will be responsible for creating the policyset above and managing which workspaces get the policies through the tf file: `./tfc-agent/tfc-agent-ecs-multi/files/sentinel_policy_set/sentinel_policy_set.tf`.

Review `admin_ws_agentdemo` workspace variables so you know what is available to your sentinel workspaces and that the tf_variables are correct in this file:

`./add_sentinel_workspace/ws_ADMIN_Sentinel_Policies.tf`
```
cd ../tfc-agent/tfc-agent-ecs-multi/files/create_tfcb_workspaces/
cp -rf ./add_sentinel_workspace/* .
git add .
git commit -m "add sentinel ws and policy_set"
git push
```
This commit should trigger `admin_ws_agentdemo` to run a plan that will create `admin_ws_sentinel`.  This workspace will create a custom policy_set from the repo you forked and apply any future changes.  Run a plan in this workspace and you should have a Sentinel policy set defined in TFCB and mapped to workspaces `ws_aws_serviceA, ws_aws_serviceB`.

1. To test your policies are working, go into service_B workspace , click on variables, and edit `dev_role_arn`.  The existing value should look something like...
```
arn:aws:iam::112233445566:role/iam-role-serviceB
```

Update this to use the service_A role instead
```
arn:aws:iam::112233445566:role/iam-role-serviceA
```
Save the variable update and run a new plan/apply from the UI.  You should see that policy checks have been added to your workflow and it will have a soft failure because the role name being assumed `serviceA` does not match the workspace name `serviceB`.

## Notes

## Additional Topics
* A [Sentinel](https://www.terraform.io/docs/cloud/sentinel/index.html) policy like [this example](https://github.com/hashicorp/terraform-guides/blob/master/governance/third-generation/aws/restrict-assumed-roles-by-workspace.sentinel) can be used to restrict which roles would be allowed in a given workspace.
* Terraform code and policies to support IAM roles and workspaces for example service-A and service-B are in `/files`.


## References
* [Terraform Cloud Agent Docs](https://www.terraform.io/docs/cloud/workspaces/agent.html)
* [Agent Pools and Agents API](https://www.terraform.io/docs/cloud/api/agents.html)
* [Agent Tokens API](https://www.terraform.io/docs/cloud/api/agent-tokens.html)