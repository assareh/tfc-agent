provider "aws" {
  region = var.region
}

# get an agent token (tfe provider not yet implemented)
# maybe better as a provisioner? writes to tmp file on worker and read it in?
data "external" "get_tfc_agent_token" {
  program = ["sh", "${path.module}/files/get_tfc_agent_token.sh"]

  query = {
    tfc_org   = var.tfc_org
    tfc_token = var.tfc_token
  }
}

# ------------ ECS ------------ #
resource "aws_ecs_cluster" "tfc_agent" {
  name = "${var.prefix}-cluster"
  tags = local.common_tags
}

resource "aws_ecs_service" "tfc_agent" {
  name            = "${var.prefix}-service"
  launch_type     = "FARGATE"
  cluster         = aws_ecs_cluster.tfc_agent.id
  task_definition = aws_ecs_task_definition.tfc_agent.arn
  desired_count   = 1
  network_configuration {
    security_groups  = [aws_security_group.tfc_agent.id]
    subnets          = [module.vpc.public_subnets[0]]
    assign_public_ip = true
  }
}

resource "aws_ecs_task_definition" "tfc_agent" {
  family                   = "${var.prefix}-task"
  execution_role_arn       = aws_iam_role.ecs_role.arn
  task_role_arn            = aws_iam_role.ecs_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  tags                     = local.common_tags
  container_definitions    = <<DEFINITION
[
  {
    "name": "tfc-agent",
    "image": "hashicorp/tfc-agent:latest",
    "essential": true,
    "memory": 256,
    "cpu": 128,
    "environment": [
      {
        "name": "TFC_AGENT_NAME",
        "value": "aws-ecs"
      },
      {
        "name": "TFC_AGENT_TOKEN",
        "value": "${data.external.get_tfc_agent_token.result["agent_token"]}"
      }
    ]
  }
]
DEFINITION
}

# ------------ IAM ------------ #
resource "aws_iam_role" "ecs_role" {
  name_prefix        = "${var.prefix}-ecs-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy_definition.json
  tags               = local.common_tags

  # Allows the role to be deleted and recreated (when needed)
  force_detach_policies = true
}

data "aws_iam_policy_document" "ecs_assume_role_policy_definition" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy" "ecs_policy" {
  name = "${var.prefix}-ecs-policy"
  role = aws_iam_role.ecs_role.id

  policy = data.aws_iam_policy_document.ecs_policy_definition.json
}

data "aws_iam_policy_document" "ecs_policy_definition" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.terraform_dev_role.arn]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_attach" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# a role for terraform consumer to assume into
# you'll need to customize IAM policies to access resources as desired
resource "aws_iam_role" "terraform_dev_role" {
  name = "terraform_dev_role"
  tags = local.common_tags

  assume_role_policy = data.aws_iam_policy_document.dev_assume_role_policy_definition.json
}

data "aws_iam_policy_document" "dev_assume_role_policy_definition" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
    principals {
      identifiers = [aws_iam_role.ecs_role.arn]
      type        = "AWS"
    }
  }
}

resource "aws_iam_role_policy_attachment" "dev_ec2_role_attach" {
  role       = aws_iam_role.terraform_dev_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# ------------ VPC ------------ #
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.55.0"
  name    = "${var.prefix}-vpc"
  tags    = local.common_tags

  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = true
}

resource "aws_security_group" "tfc_agent" {
  name_prefix = "${var.prefix}-sg"
  description = "Security group for tfc-agent-vpc"
  vpc_id      = module.vpc.vpc_id
  tags        = local.common_tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_egress" {
  security_group_id = aws_security_group.tfc_agent.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks = [
  "0.0.0.0/0"]
}
