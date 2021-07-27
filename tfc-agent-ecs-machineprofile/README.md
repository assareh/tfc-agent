# Credential free provisioning with Terraform Cloud Agent on AWS ECS

This repository provides an example of running multiple [tfc-agent](https://hub.docker.com/r/hashicorp/tfc-agent) pools on a single AWS ECS cluster.  It uses the same credential free provisioning with [Assume Role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#assume-role) as the original example.  Additionally, it includes an example `/iam` folder that the IAM team could create per service's workspace to allow a service read access to only its IAM credentials.  These credentials can be automatically pulled from TFC using remote state (TBD).

## Prerequisites
* [Terraform Cloud Business Tier](https://www.hashicorp.com/blog/announcing-hashicorp-terraform-cloud-business)
* Create 2 agent pools and save the tokens for variables in the producer workspace.
  
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