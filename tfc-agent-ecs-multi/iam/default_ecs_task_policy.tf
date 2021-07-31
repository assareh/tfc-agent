# ECS Task Policy that will assume a specific Service Role
data "aws_iam_policy_document" "ecs_assume_role_policy_definition" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
    principals {
      #identifiers = [aws_iam_role.tfc_agent_task.arn]
      identifiers = [aws_iam_role.tfc_agent_task.arn]
      type        = "AWS"
    }
  }
}