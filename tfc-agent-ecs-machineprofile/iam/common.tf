# ECS Agent Policy all Service Roles should assume
data "aws_iam_policy_document" "ecs_assume_role_policy_definition" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
    principals {
      identifiers = ["arn:aws:iam::711129375688:role/presto-ecs-tfc-agent-role"]
      type        = "AWS"
    }
  }
}

# Standard IAM Role Tags
locals {
  common_tags = {
    owner              = "presto"
    se-region          = "norcal"
    purpose            = "Manage multiple IAM roles"
    ttl                = 0 # hours
    terraform          = "true"  # true/false
    hc-internet-facing = "false" # true/false
  }
}