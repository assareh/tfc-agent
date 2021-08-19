# Terraform Cloud Agent in Amazon ECS Consumer Workspace

No AWS credentials are required in this workspace. AWS access is obtained through the tfc-agent. The  AWS ECS task is granted the IAM role and these AWS credentials are sourced into the tfc-agent's running environment for terraform to use. A Terraform user does not need to provide any aws credentials or use assume_role in their terraform code.  Just define the aws provider.
```
provider "aws" {
  region = "us-west-2"
}
```

In this model it is important to enforce least privilege on Terraform Cloud workspace access using [Single Sign-on](https://www.terraform.io/docs/cloud/users-teams-organizations/single-sign-on.html) and the built-in [RBAC controls](https://www.terraform.io/docs/cloud/workspaces/access.html).