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
4. Next go to Settings -> General -> Share state globally or with `ws_aws_agent_ecs` and your ADMIN workspace.  This attribute can be configured with IaC by adding it to the module in `./modules/workspace/main.tf`. 

* We put all service IAM roles into one workspace in this example.  In large environments this workspace could be broken into smaller workspaces for each AWS account, or service.  Alternatively, you can keep all IAM configs in 1 workspace and create child workspaces for each service/team to manage specific outputs only that the service team should consume.

6. Next run an apply in `ws_aws_agent_ecs` to create your ECS cluster which requires  access to the ws_aws_iam state file for its IAM policies.
7. Now that we have our IAM and ECS services ready lets start building workspaces for our individual service teams to use.  Each team will have access to their own workspace and the IAM role that was created for them by the IAM team.
```
cd ./tfc-agent-ecs-multi/files/create-tfcb-workspaces
cp ./add_service_workspaces/* .
git add .
git commit -m "Adding serviceA, serviceB workspaces"
git push
```
Your admin workspace should pick up this change and automatically create your service workspaces `ws_aws_serviceA, ws_aws_serviceB`.  Two service workspaces have been created for you.  Look at the variables in these workspaces and you should see they were created with no credentials.  You are leveraging the IAM roles previously built and using assume_role.

8. Test each service workstation roles are working by running a job.  They are pre-configured with IaC to build an EC2 instance.

## Setup
Create the `producer` workspace and point to `/producer` directory. It contains an example of registering and running the tfc-agent on ECS Fargate, along with necessary IAM policies and roles. It creates a `terraform_dev_role` to be using by the consumer who is provisioning infrastructure with Terraform.  We are creating an additional `iam_role_ecs_agent` role that will be used by our consumer using a machine_profile instead.  This workspace requires a token for each tfc_agent_pool it will manage.  These agent pools should be setup as a pre-req and you can do this with IaC using the TFE provider.

The `/iam` workspace will manage IAM roles for the various consumer workspaces.  In production this could be a ws per consumer to add additional security around roles you can assume.  In my environment I'm using a single workspace (aws_aws_iam) to manage the roles for my 2 service workspaces.
* ws_aws_serviceA
* ws_aws_serviceB

The `consumer` and `consumer_machine_profile` workspace provides an example of assuming that role and provisioning an instance without placing credentials in the Terraform Cloud workspace.


## Notes
* Please ensure the consumer workspace [Execution Mode](https://www.terraform.io/docs/cloud/workspaces/settings.html#execution-mode) is set to Agent!

## Additional Topics
* A [Sentinel](https://www.terraform.io/docs/cloud/sentinel/index.html) policy like [this example](https://github.com/hashicorp/terraform-guides/blob/master/governance/third-generation/aws/restrict-assumed-roles-by-workspace.sentinel) can be used to restrict which roles would be allowed in a given workspace.
* Terraform code and policies to support IAM roles and workspaces for example service-A and service-B are in `/files`.


## References
* [Terraform Cloud Agent Docs](https://www.terraform.io/docs/cloud/workspaces/agent.html)
* [Agent Pools and Agents API](https://www.terraform.io/docs/cloud/api/agents.html)
* [Agent Tokens API](https://www.terraform.io/docs/cloud/api/agent-tokens.html)