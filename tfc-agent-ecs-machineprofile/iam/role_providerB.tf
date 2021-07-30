
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
    #resources = var.trusted_entity_list
    resources = ["arn:aws:iam::711129375688:role/*"]
  }
}

resource "aws_iam_role_policy_attachment" "tfc_agent_task_task_policy" {
  role       = aws_iam_role.tfc_agent_task.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
