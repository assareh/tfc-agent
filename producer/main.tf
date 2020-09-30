provider "aws" {
  region = var.region
}

resource "aws_ecs_cluster" "tfc_agent" {
  name = "${var.prefix}-cluster"
  tags = local.common_tags
}

resource "aws_ecs_service" "tfc_agent" {
  name            = "${var.prefix}-service"
  cluster         = aws_ecs_cluster.tfc_agent.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.tfc_agent.arn
  desired_count   = 2
  network_configuration {
    security_groups  = [aws_security_group.tfc_agent.id]
    subnets          = [module.vpc.public_subnets[0]]
    assign_public_ip = true
  }
}

resource "aws_ecs_task_definition" "tfc_agent" {
  family                   = "${var.prefix}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  container_definitions    = data.template_file.agent.rendered
  execution_role_arn       = aws_iam_role.agent_task_exec.arn
  task_role_arn            = aws_iam_role.agent.arn
  cpu                      = 256
  memory                   = 512
  tags                     = local.common_tags
}

data "template_file" "agent" {
  template = file("${path.module}/files/task_definition.json")

  vars = {
    tfc_agent_token_parameter_arn = aws_ssm_parameter.agent_token.arn
  }
}

resource "aws_ssm_parameter" "agent_token" {
  name        = "${var.prefix}-tfc-agent-token"
  description = "Terraform Cloud agent token"
  type        = "SecureString"
  value       = var.tfc_agent_token
}

# task execution role for task init
resource "aws_iam_role" "agent_task_exec" {
  name               = "${var.prefix}-ecs-tfc-agent-task-exec-role"
  assume_role_policy = data.aws_iam_policy_document.agent_assume_role_policy_definition.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy" "agent_task_exec_config" {
  role   = aws_iam_role.agent_task_exec.name
  name   = "AccessSSMParameterforAgentToken"
  policy = data.aws_iam_policy_document.agent_task_exec_config.json
}

resource "aws_iam_role_policy_attachment" "agent_task_exec_policy" {
  role       = aws_iam_role.agent_task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "agent_task_exec_config" {
  statement {
    effect = "Allow"
    actions = ["ssm:GetParameters"]
    resources = [aws_ssm_parameter.agent_token.arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup"]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

# task role for agent
resource "aws_iam_role" "agent" {
  name               = "${var.prefix}-ecs-tfc-agent-role"
  assume_role_policy = data.aws_iam_policy_document.agent_assume_role_policy_definition.json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "agent_assume_role_policy_definition" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy" "agent_policy" {
  name = "${var.prefix}-ecs-tfc-agent-policy"
  role = aws_iam_role.agent.id

  policy = data.aws_iam_policy_document.agent_policy_definition.json
}

data "aws_iam_policy_document" "agent_policy_definition" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.terraform_dev_role.arn]
  }
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
      identifiers = [aws_iam_role.agent.arn]
      type        = "AWS"
    }
  }
}

resource "aws_iam_role_policy_attachment" "dev_ec2_role_attach" {
  role       = aws_iam_role.terraform_dev_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# networking
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.55.0"
  name    = "${var.prefix}-vpc"
  tags    = local.common_tags

  cidr = "10.0.0.0/16"

  azs            = ["${var.region}a"]
  public_subnets = ["10.0.101.0/24"]

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
