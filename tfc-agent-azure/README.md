# Credential free provisioning with Terraform Cloud Agent on Azure Container Instances

This repository provides an example of running [tfc-agent](https://hub.docker.com/r/hashicorp/tfc-agent) on ACI, and shows how you can leverage tfc-agent to perform credential free provisioning using [Azure MSI](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview). Though this simple example shows usage within a single subscription, this pattern is used to allow provisioning across subscriptions without requiring Azure credentials in Terraform workspaces.

## Setup
The `producer` workspace contains an example of registering and running the tfc-agent on ACI, along with a necessary AAD role assignment. For simplicity I am using the built in Contributor role with a subscription scope, however custom roles and narrower scopes can be defined.

The `consumer` workspace provides an example of provisioning an instance without placing credentials in the Terraform Cloud workspace.

## Prerequisites
* [Terraform Cloud Business Tier](https://www.hashicorp.com/blog/announcing-hashicorp-terraform-cloud-business)

## Steps
1. Configure and provision the `producer` workspace. See [README](./producer/README.md) for instructions.
2. Configure and provision the `consumer` workspace. See [README](./consumer/README.md) for instructions.

## Notes
* Please ensure the consumer workspace [Execution Mode](https://www.terraform.io/docs/cloud/workspaces/settings.html#execution-mode) is set to Agent!

## References
* [Terraform Cloud Agent Docs](https://www.terraform.io/docs/cloud/workspaces/agent.html)
* [Agent Pools and Agents API](https://www.terraform.io/docs/cloud/api/agents.html)
* [Agent Tokens API](https://www.terraform.io/docs/cloud/api/agent-tokens.html)
* [Azure Provider Authentication Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure)
