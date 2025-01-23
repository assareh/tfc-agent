# HCP Terraform Agent in Google Compute Engine Consumer Workspace

No GCP credentials are required in this workspace. GCP access is obtained through the tfc-agent. The tfc-agent running in GCE is granted IAM permissions to provision resources.

In this model it is important to enforce least privilege on HCP Terraform workspace access using [Single Sign-on](https://developer.hashicorp.com/terraform/cloud-docs/users-teams-organizations/single-sign-on) and the built-in [RBAC controls](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings/access).

## Usage

You can verify the impersonation by viewing the IAM Audit Logs in the GCP console Logs Explorer.

### Execution Mode
NOTE: The [Execution Mode](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings#execution-mode) of this workspace must be set to Agent, and the appropriate agent pool must be selected. Please refer to the [documentation](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings#execution-mode) for instructions on how to configure workspaces to use the agent in the HCP Terraform console.

Additionally, as of version 0.24.0 of the [tfe provider](https://registry.terraform.io/providers/hashicorp/tfe/latest) workspace execution mode may be configured and managed with Terraform via the `execution_mode` and `agent_pool_id` arguments of the `tfe_workspace` resource.

Prior to the addition of these attributes to the tfe provider, I had written a helper script to configure workspace execution mode on workspaces using the HCP Terraform API. That script remains available [here](../../tfc-agent-ecs/consumer/files/README.md).

### Variables
Please provide a value for the following required [variables](https://developer.hashicorp.com/terraform/language/values/variables#assigning-values-to-root-module-variables):
* `dev_role_sa`: The Service Account email of the dev role to be impersonated. This is the value of output `terraform-dev-role` from the Producer workspace.
* `gcp_project`: The GCP Project name. This is the value of output `gcp_project` from the Producer workspace.

In addition, I recommend that you review all other variables and configure their values according to your specifications.

`ttl` and `common_tags` are used only for tagging and are completely optional.

## References
* [Permissions](https://developer.hashicorp.com/terraform/cloud-docs/users-teams-organizations/permissions)
* [Manage Permissions in HCP Terraform](https://developer.hashicorp.com/terraform/tutorials/cloud/cloud-permissions)
