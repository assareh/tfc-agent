# Running Terraform Cloud Agent in Amazon ECS

This repository provides an example of running [tfc-agent](https://hub.docker.com/r/hashicorp/tfc-agent) in AWS ECS, and shows how you can leverage tfc-agent to perform credential free provisioning using [Assume Role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#assume-role). Though this simple example shows usage within a single AWS account, this pattern can easily be used to allow provisioning across accounts without requiring AWS credentials in workspaces.

## Setup
The `producer` workspace contains an example of registering and running the tfc-agent on ECS Fargate, along with necessary IAM policies and roles. It creates a `terraform_dev_role` to be using by the consumer who is provisioining infrastructure with Terraform.

The `consumer` workspace provides an example usage that enables you to provision with assume role, bypassing the need to place credentials in your Terraform Cloud workspace.

## Prerequisites
* [Terraform Cloud Business Tier](https://www.hashicorp.com/blog/announcing-hashicorp-terraform-cloud-business)

## Steps
1. Configure and provision the `producer` workspace.
2. Configure and provision the `consumer` workspace, using the `terraform_dev_role` created in step 1.

## Notes
* Please ensure the consumer workspace [Execution Mode](https://www.terraform.io/docs/cloud/workspaces/settings.html#execution-mode) is set to Agent!
* When you are done you will currently need to manually remove your agent tokens. This can be done by API call, or from the following URL: https://app.terraform.io/app/<YOUR_ORG_NAME>/settings/agents. Click on `Manage Tokens`.

## References
* [Terraform Cloud Agents](https://www.terraform.io/docs/cloud/workspaces/agent.html)
* [Agent Pools and Agents API](https://www.terraform.io/docs/cloud/api/agents.html)
* [Agent Tokens API](https://www.terraform.io/docs/cloud/api/agent-tokens.html)
