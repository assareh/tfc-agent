# Terraform Cloud Agent in Amazon ECS Consumer Workspace

No AWS credentials are required in this workspace. AWS access is obtained through the tfc-agent. The tfc-agent running in AWS ECS is granted IAM permissions to assume roles. A Terraform user can invoke a role in their aws provider as follows:
```
provider "aws" {
  assume_role {
    role_arn = ...
  }
...
```

In this model it is vital to enforce least privilege on Terraform Cloud workspace access using [Single Sign-on](https://www.terraform.io/docs/cloud/users-teams-organizations/single-sign-on.html) and the built-in [RBAC controls](https://www.terraform.io/docs/cloud/workspaces/access.html).

## Steps
Set `dev_role_arn` to the value of output `terraform_dev_role` from the Producer workspace. The provided tfvars file may be used. (Remove .example from the file name.)

Provide values for required variables

## References
* [Permissions](https://www.terraform.io/docs/cloud/users-teams-organizations/permissions.html)
* [Manage Permissions in Terraform Cloud](https://learn.hashicorp.com/tutorials/terraform/cloud-permissions)
