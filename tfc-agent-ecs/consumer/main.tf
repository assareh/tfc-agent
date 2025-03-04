provider "aws" {
  region = var.region

  assume_role {
    role_arn     = var.aws_role_arn
    session_name = var.TFC_RUN_ID
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

resource "aws_vpc" "example" {
  cidr_block = var.cidr_block
}

resource "aws_subnet" "example" {
  vpc_id     = aws_vpc.example.id
  cidr_block = var.cidr_block
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.amazon-linux.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.example.id
}
