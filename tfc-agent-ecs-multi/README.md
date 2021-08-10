# Credential free provisioning with Terraform Cloud Agent on AWS ECS

This repository provides an example of running multiple [tfc-agent](https://hub.docker.com/r/hashicorp/tfc-agent) pools each tied to their own ECS fargate service within the same ECS cluster.  This is helpful for any environment using TFCB that needs to issolate service team provisioning tasks and permissions from eachother, support multiple AWS accounts, and do it in a scalable way.   It uses the same credential free provisioning in the original [tfc-agent-ecs](https://github.com/assareh/tfc-agent/tree/master/tfc-agent-ecs) example.  To support multiple teams or AWS accounts better we will use multiple workspaces to break out the various roles and responsibilities.  For efficient administration of these TFCB workspaces we will leverage the TFE provider to build and manage our workspaces with IaC too.  

## TFCB Workspaces Overview
1. [Optional] Admin-TFE-Workspace: This can be used as a centralized admin workspaces that contains all sensitive or standard inputs and should only be accessible by owners.  You can use this to initially populate newly created child workspaces with already encrypted variables.  This may not meet all production security requirements so check with the secops team.
2. First create `ws_aws_iam` to manage IAM access. This workspace will manage service roles so ECS can assume the serviceX role and run tasks with the right serviceX permissions.  Additionally serviceX will get an agent pool, token, and AWS SSM param with the token built fully isolating its TFCB runs from other services.
   1. To onboard a new service update this workspace first.
   2. Configure your service or use exammples for serviceA and serviceB.
3. Next create `ws_aws_ecs_tfcagents`.  This is the ECS cluster that will isolate every service's TFCB runs by creating an ECS service per service.  This requires IAM roles so should be ran after ws_aws_iam.  This workspace contains the ECS task definitions for each service it supports and will need to be updated when onboarding new services.
4. Onboard new services...
   1. Add the service to `ws_aws_iam` so you have the service role, and tfcagent pool and token.
   2. Add the service to `ws_aws_ecs_tfcagents` so you have your specific service task defined
   3. Create a new workspace for the service.  This will contain only the tf the service wants to provision.  The tf HCL will use assume role to provision resources without requiring any credentials.

## Prerequisites
* [Terraform Cloud Business Tier](https://www.hashicorp.com/blog/announcing-hashicorp-terraform-cloud-business) to run Agents
* AWS Credentials to provision infrastructure (assume_role, EC2)

## TFCB Setup
1. First fork or clone this repo in your github.com account.
```
cd tfc-agent-ecs-multi/files/create_tfcb_workspaces
```
1. Read `TFE_Workspace_README.md` and follow the setup steps to create your admin workspace.  When creating your admin workspace source your AWS Credentials into your shell env to have them added to your admin workspace.  The child workspaces we are about to create for IAM and ECS components can easily pull these as encrypted values at setup time to save you the trouble of inputing them manually.
2. Once your admin workspace is created it should be linked to this repo and have a working directory `tfc-agent-ecs-multi/files/create_tfcb_workspaces` set that points to sample IaC that will manage all your workspaces. Use the UI to review this config and then manually trigger a terraform plan and apply in your new admin workspace. Go to `Workspace -> Actions -> Start plan now`.  You should see new workspaces `ws_aws_iam, ws_aws_agent_ecs` created.
   * If you want your child workspaces to inherit AWS creds from the admin workspace uncomment the following lines in both files (`ws_aws_ecs_tfcagents.tf, ws_aws_iam.tf`)
      ```
      #aws_secret_access_key = "${var.aws_secret_access_key}"
      #aws_access_key_id = "${var.aws_access_key_id}"
      ```
   If you already ran the admin workspace thats fine.  Just run it again to pick up these changes to your IaC.

3. Now run an apply in `ws_aws_iam` to create all your service teams IAM roles and policies.  This workspace is also responsible for creating tfc_agent pools, and tokens per service. It will push each token into an SSM param store owned by the service. The ECS task will be able to securely pull the right service token at runtime ensuring services are each using their agent_pool and have complete isolation.
4. Next go to Settings -> General -> and review the Share state globally that we enabled.  This will allow `ws_aws_agent_ecs` and your ADMIN workspace to have access to the IAM workspace managing all the security outputs.
   * For better security you should update this to only allow specific workspaces versus sharing state globally.
   * We put all service IAM roles into one workspace in this example.  In large environments this workspace could be broken into smaller workspaces for each AWS account, or service.  Alternatively, you can keep all IAM configs in 1 workspace and create child workspaces to manage outputs that each service/team can access.

5. Next run an apply in `ws_aws_agent_ecs` to create your ECS cluster which requires  access to the ws_aws_iam state file for its IAM policies.
6. Now that you have the IAM and ECS services built you are ready to build workspaces for the individual service teams to use.  Each team will have access to their own workspace and the IAM role that was created for them by the IAM workspace/team.

   Copy the service workspace creation code into the working directory and commit it.
   ```
   cd ./tfc-agent-ecs-multi/files/create-tfcb-workspaces
   cp ./add_service_workspaces/* .
   git add .
   git commit -m "Adding serviceA, serviceB workspaces"
   git push
   ```
Your admin workspace should pick up this change and automatically create your service workspaces `ws_aws_serviceA, ws_aws_serviceB`.  Verify thse workspaces have been created in the UI and look at their configuration.  These workspaces are a little different from our main services.  They are using the [Agent Execution Mode](https://www.terraform.io/docs/cloud/workspaces/settings.html#execution-mode).  Look at the variables in these workspaces and verify they were created with no AWS credentials.  These workspaces will be leveraging the IAM roles previously built for them by using assume_role in their terraform code.

1. Test each service workstation roles are working by running a job.  They are pre-configured with IaC to build an EC2 instance.

## Notes

## Additional Topics
* A [Sentinel](https://www.terraform.io/docs/cloud/sentinel/index.html) policy like [this example](https://github.com/hashicorp/terraform-guides/blob/master/governance/third-generation/aws/restrict-assumed-roles-by-workspace.sentinel) can be used to restrict which roles would be allowed in a given workspace.
* Terraform code and policies to support IAM roles and workspaces for example service-A and service-B are in `/files`.


## References
* [Terraform Cloud Agent Docs](https://www.terraform.io/docs/cloud/workspaces/agent.html)
* [Agent Pools and Agents API](https://www.terraform.io/docs/cloud/api/agents.html)
* [Agent Tokens API](https://www.terraform.io/docs/cloud/api/agent-tokens.html)