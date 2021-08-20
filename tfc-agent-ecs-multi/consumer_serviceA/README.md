# Terraform Cloud Agent in Amazon ECS Consumer Workspace

No AWS credentials are required in this workspace. AWS access is obtained through the tfc-agent. The  AWS ECS task is granted the IAM role and these AWS credentials are sourced into the tfc-agent's running environment for terraform to use. A Terraform user does not need to provide any aws credentials or use assume_role in their terraform code.  Just define the aws provider like any other provider.
```
provider "aws" {
  region = "us-west-2"
}
```
In this model, the ECS shared service will get the correct Role information from the IAM workspace for the service and setup the ECS service task to use it.  The serice workspace and team do not ever need to have the role or permissions to assume_role.