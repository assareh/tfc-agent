# Credential free provisioning with Terraform Cloud Agent on AWS ECS

This repository provides an example of running [tfc-agent](https://hub.docker.com/r/hashicorp/tfc-agent) on AWS ECS, and shows how you can leverage tfc-agent to perform credential free provisioning using [Assume Role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#assume-role). Though this simple example shows usage within a single AWS account, this pattern is used to allow provisioning across accounts without requiring AWS credentials in Terraform workspaces.

## Setup
The `producer` workspace contains an example of registering and running the tfc-agent on ECS Fargate, along with necessary IAM policies and roles. It creates a `terraform_dev_role` to be using by the consumer who is provisioning infrastructure with Terraform.

The `consumer` workspace provides an example of assuming that role and provisioning an instance without placing credentials in the Terraform Cloud workspace.

## Prerequisites
* [Terraform Cloud Business Tier](https://www.hashicorp.com/blog/announcing-hashicorp-terraform-cloud-business)

## Steps
1. Configure and provision the `producer` workspace. See [README](./producer/README.md) for instructions.
2. Configure and provision the `consumer` workspace, using the `terraform_dev_role` created in step 1. See [README](./consumer/README.md) for instructions.

## Notes
* Please ensure the consumer workspace [Execution Mode](https://www.terraform.io/docs/cloud/workspaces/settings.html#execution-mode) is set to Agent!
* Helper scripts are provided to create and delete agent tokens. This can also be done from the Terraform Cloud Organization Settings.

## Additional Topics
* Declaring Assume Role in the provider block is not necessarily required. IAM permissions given to the agent role directly will be available to Terraform runs without any configuration necessary. 
* The agent image and environment can be customized. For example, abstracting the role ARNs from the Terraform consumers entirely is possible if you were to embed an AWS CLI config file into the agent image. In this scenario users can select an AWS role or profile with `profile = "dev"` in their provider block. 

## References
* [Terraform Cloud Agents](https://www.terraform.io/docs/cloud/workspaces/agent.html)
* [Agent Pools and Agents API](https://www.terraform.io/docs/cloud/api/agents.html)
* [Agent Tokens API](https://www.terraform.io/docs/cloud/api/agent-tokens.html)
