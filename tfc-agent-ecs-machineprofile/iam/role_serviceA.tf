# Add TFC agent token to SSM so ECS can access serviceA's TFC agent_pool
resource "aws_ssm_parameter" "serviceA_agent_token" {
  name        = "${var.prefix}-serviceA-tfc-agent-token"
  description = "Terraform Cloud agent token"
  type        = "SecureString"
  value       = var.ecs_agent_pool_serviceA_token
}

# ECS init role with access to SSM param container agent_pool token (execution_role_arn)
resource "aws_iam_role" "ecs_init_serviceA" {
  name               = "${var.prefix}-ecs_init_serviceA-role"
  assume_role_policy = data.aws_iam_policy_document.tfc_agent_task_assume_role_policy_definition.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy" "ecs_init_serviceA_policy" {
  role   = aws_iam_role.ecs_init_serviceA.name
  name   = "AccessSSMParameterforAgentToken"
  policy = data.aws_iam_policy_document.ecs_init_serviceA_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_init_serviceA_policy" {
  role       = aws_iam_role.ecs_init_serviceA.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_init_serviceA_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters"]
    resources = [aws_ssm_parameter.serviceA_agent_token.arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup"]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

#
# Create role for serviceA with EC2 Full Access.
# This role will be assumed by the TFC agent running as an ECS task
#
resource "aws_iam_role" "serviceA" {
  name = "iam-role-serviceA"
  tags = local.common_tags
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy_definition.json
}

resource "aws_iam_role_policy_attachment" "serviceA_attach" {
  role       = aws_iam_role.serviceA.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

output "iam_role_serviceA" {
  value = aws_iam_role.serviceA.arn
}