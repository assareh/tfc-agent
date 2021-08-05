provider "aws" {
  region = var.region
}

# TFCB Workspace administration
# For each service workspace Add agent_pool and token.
# The ECS service task running tfc-agent will use these to connect.

# monthly timestamp
locals {
    #time = "${formatdate("DDMMYYYY-hhmm",timestamp())}"
    time = "${formatdate("MM-YYYY",timestamp())}"
}

# ServiceA Agent Pool
resource "tfe_agent_pool" "ecs-agent-pool-serviceA" {
  name         = "ecs-agent-pool-serviceA"
  organization = var.organization
}
resource "tfe_agent_token" "ecs-agent-serviceA-token" {
  agent_pool_id = tfe_agent_pool.ecs-agent-pool-serviceA.id
  description   = "ecs-agent-serviceA-token-${local.time}"
}

# ServiceB Agent Pool
resource "tfe_agent_pool" "ecs-agent-pool-serviceB" {
  name         = "ecs-agent-pool-serviceB"
  organization = var.organization
}
resource "tfe_agent_token" "ecs-agent-serviceB-token" {
  agent_pool_id = tfe_agent_pool.ecs-agent-pool-serviceB.id
  description   = "ecs-agent-serviceB-token-${local.time}"
}

# Default ECS Task Policy that will assume a specific Service Role
data "aws_iam_policy_document" "ecs_assume_role_policy_definition" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
    principals {
      identifiers = [aws_iam_role.tfc_agent_task.arn]
      type        = "AWS"
    }
  }
}