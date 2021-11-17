provider "aws" {
  region = var.region

  assume_role {
    role_arn     = var.dev_role_arn
    session_name = "terraform"
  }

  default_tags {
    tags = local.common_tags
  }
}

data "aws_caller_identity" "current" {
}

data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.amazon-linux.id
  instance_type = "t3.micro"
}
