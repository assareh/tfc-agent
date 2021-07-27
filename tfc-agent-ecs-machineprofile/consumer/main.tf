provider "aws" {
  region = "us-west-2"
  assume_role {
    role_arn     = var.dev_role_arn
    session_name = "terraform"
  }
}

data "aws_caller_identity" "current" {
}

data "aws_ami" "ubuntu-vault-oss" {
  owners      = ["679593333241"] # HashiCorp
  most_recent = true

  filter {
    name   = "name"
    values = ["hashicorp/marketplace/vault-1.5.0-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "vault" {
  ami           = data.aws_ami.ubuntu-vault-oss.id
  instance_type = "t3.micro"

  tags = local.common_tags
}
