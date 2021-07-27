# task execution role for agent init
resource "aws_iam_role" "agent_init" {
  name               = "${var.prefix}-ecs-tfc-agent-task-init-role"
  assume_role_policy = data.aws_iam_policy_document.agent_assume_role_policy_definition.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy" "agent_init_policy" {
  role   = aws_iam_role.agent_init.name
  name   = "AccessSSMParameterforAgentToken"
  policy = data.aws_iam_policy_document.agent_init_policy.json
}

resource "aws_iam_role_policy_attachment" "agent_init_policy" {
  role       = aws_iam_role.agent_init.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "agent_init_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters"]
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
    #resources = [aws_iam_role.terraform_dev_role.arn]
    resources = ["arn:aws:iam::711129375688:role/*"]
  }
}

resource "aws_iam_role_policy_attachment" "agent_task_policy" {
  role       = aws_iam_role.agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# a role for terraform consumer to assume into
# you'll need to customize IAM policies to access resources as desired
resource "aws_iam_role" "terraform_dev_role" {
  name = "${var.prefix}-terraform_dev_role"
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

output "agent_init_arn" {
  value = aws_iam_role.agent_init.arn
}

output "agent_arn" {
  value = aws_iam_role.agent.arn
}