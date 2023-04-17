# Terraform Cloud Agent in Amazon ECS Consumer Workspace

No AWS credentials are required in this workspace. AWS access is obtained through the tfc-agent. The tfc-agent running in AWS ECS is granted IAM permissions to assume roles. A Terraform user can invoke a role in their aws provider as follows:
```
provider "aws" {
  assume_role {
    role_arn     = var.dev_role_arn
    session_name = "terraform"
  }
...
```

In this model it is important to enforce least privilege on Terraform Cloud workspace access using [Single Sign-on](https://www.terraform.io/docs/cloud/users-teams-organizations/single-sign-on.html) and the built-in [RBAC controls](https://www.terraform.io/docs/cloud/workspaces/access.html).
