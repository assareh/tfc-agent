
# task role for tfc agent
resource "aws_iam_role" "tfc_agent_task" {
  name               = "${var.prefix}-ecs-tfc_agent_task-role"
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
    resources = var.trusted_entity_list
  }
}

resource "aws_iam_role_policy_attachment" "tfc_agent_task_task_policy" {
  role       = aws_iam_role.tfc_agent_task.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

output "ecs_init_serviceB_arn" {
  value = aws_iam_role.ecs_init_serviceB.arn
}
output "agent_arn" {
  value = aws_iam_role.tfc_agent_task.arn
}
output "ecs_init_serviceB_id" {
  value = aws_iam_role.ecs_init_serviceB.id
}
output "agent_id" {
  value = aws_iam_role.tfc_agent_task.id
}
output "aws_ssm_param_serviceB_tfc_arn" {
  value = aws_ssm_parameter.agent_token.arn
}
