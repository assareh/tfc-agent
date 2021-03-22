# Terraform Cloud Agent in Amazon ECS Consumer Workspace

No AWS credentials are required in this workspace. AWS access is obtained through the tfc-agent. The tfc-agent running in AWS ECS is granted IAM permissions to assume roles. A Terraform user can invoke a role in their aws provider as follows:
```
provider "aws" {
  assume_role {
    role_arn = ...
  }
...
```

In this model it is important to enforce least privilege on Terraform Cloud workspace access using [Single Sign-on](https://www.terraform.io/docs/cloud/users-teams-organizations/single-sign-on.html) and the built-in [RBAC controls](https://www.terraform.io/docs/cloud/workspaces/access.html).

## Usage

### Execution Mode
NOTE: The [Execution Mode](https://www.terraform.io/docs/cloud/workspaces/settings.html#execution-mode) of this workspace must be set to Agent, and the appropriate agent pool must be selected. Please refer to the [documentation](https://www.terraform.io/docs/cloud/agents/index.html#configuring-workspaces-to-use-the-agent) for instructions on how to configure workspaces to use the agent in the Terraform Cloud console.

Additionally, as of version 0.24.0 of the [tfe provider](https://registry.terraform.io/providers/hashicorp/tfe/latest) workspace execution mode may be configured and managed with Terraform via the `execution_mode` and `agent_pool_id` arguments of the `tfe_workspace` resource.

Prior to the addition of these attributes to the tfe provider, I had written a helper script to configure workspace execution mode on workspaces using the Terraform Cloud API. That script remains available [here](files/README.md).

### Variables
Please provide values for the following required variables:
* `prefix`: a name prefix to add to the resources
* `dev_role_arn`: The Amazon Resource Name of the dev role to be assumed. This is the value of output `terraform_dev_role` from the Producer workspace.

In addition, I recommend that you review all other variables and configure their values according to your specifications. The provided tfvars file may be used. (Remove .example from the file name.)

`ttl` and `common_tags` are used only for tagging and are completely optional.

## References
* [Permissions](https://www.terraform.io/docs/cloud/users-teams-organizations/permissions.html)
* [Manage Permissions in Terraform Cloud](https://learn.hashicorp.com/tutorials/terraform/cloud-permissions)
