# Add TFC agent token to SSM to securely pass it at ECS task start
resource "aws_ssm_parameter" "agent_token" {
  name        = "${var.prefix}-tfc-agent-token"
  description = "Terraform Cloud agent token"
  type        = "SecureString"
  value       = var.ecs_agent_pool_serviceB_token
}

# task execution role for agent init
resource "aws_iam_role" "ecs_init_serviceB" {
  name               = "${var.prefix}-ecs-tfc-agent-task-init-role"
  assume_role_policy = data.aws_iam_policy_document.tfc_agent_task_assume_role_policy_definition.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy" "ecs_init_serviceB_policy" {
  role   = aws_iam_role.ecs_init_serviceB.name
  name   = "AccessSSMParameterforAgentToken"
  policy = data.aws_iam_policy_document.ecs_init_serviceB_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_init_serviceB_policy" {
  role       = aws_iam_role.ecs_init_serviceB.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_init_serviceB_policy" {
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

# task role for tfc agent
resource "aws_iam_role" "tfc_agent_task" {
  name               = "${var.prefix}-ecs-tfc-tfc_agent_task-role"
  assume_role_policy = data.aws_iam_policy_document.tfc_agent_task_assume_role_policy_definition.json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "tfc_agent_task_assume_role_policy_definition" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy" "tfc_agent_task_policy" {
  name = "${var.prefix}-ecs-tfc-tfc_agent_task-policy"
  role = aws_iam_role.tfc_agent_task.id

  policy = data.aws_iam_policy_document.tfc_agent_task_policy_definition.json
}

data "aws_iam_policy_document" "tfc_agent_task_policy_definition" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    #resources = [aws_iam_role.terraform_dev_role.arn]
    resources = ["arn:aws:iam::711129375688:role/*"]
  }
}

resource "aws_iam_role_policy_attachment" "tfc_agent_task_task_policy" {
  role       = aws_iam_role.tfc_agent_task.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

output "agent_init_arn" {
  value = aws_iam_role.ecs_init_serviceB.arn
}
output "agent_arn" {
  value = aws_iam_role.tfc_agent_task.arn
}
output "agent_init_id" {
  value = aws_iam_role.ecs_init_serviceB.id
}
output "agent_id" {
  value = aws_iam_role.tfc_agent_task.id
}