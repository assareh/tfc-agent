variable "TFC_WORKSPACE_NAME" {
  type    = string
  default = "" # An error occurs when you are running TF backend other than Terraform Cloud
}

data "tfe_outputs" "doormat_role" {
  organization = "hashidemos"
  workspace    = "doormat-aws-infra"
}

provider "doormat" {}

data "doormat_aws_credentials" "creds" {
  provider = doormat

  role_arn = "${data.tfe_outputs.doormat_role.values.role_arn_base}${var.TFC_WORKSPACE_NAME}"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.31.0"
    }
    doormat = {
      source  = "doormat.hashicorp.services/hashicorp-security/doormat"
      version = "~> 0.0.2"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = ">= 0.26.0"
    }
  }

required_version = ">= 1.1"
}
