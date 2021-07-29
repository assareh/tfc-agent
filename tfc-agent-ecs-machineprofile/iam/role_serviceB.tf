# Add TFC agent token to SSM so ECS can access serviceB's TFC agent_pool
resource "aws_ssm_parameter" "agent_token" {
  name        = "${var.prefix}-serviceB-tfc-agent-token"
  description = "Terraform Cloud agent token"
  type        = "SecureString"
  value       = var.ecs_agent_pool_serviceB_token
}

# ECS init role with access to SSM param container agent_pool token (execution_role_arn)
resource "aws_iam_role" "ecs_init_serviceB" {
  name               = "${var.prefix}-ecs_init_serviceB-role"
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

#
# Create role for serviceB with EC2 Full Access.
# This role will be assumed by the TFC agent running as an ECS task
#
resource "aws_iam_role" "serviceB" {
  name = "iam-role-serviceB"
  tags = local.common_tags
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy_definition.json
}

resource "aws_iam_role_policy_attachment" "serviceB_attach" {
  role       = aws_iam_role.serviceB.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

output "iam_role_serviceB" {
  value = aws_iam_role.serviceB.arn
}