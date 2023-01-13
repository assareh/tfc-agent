# ECS task agent role.  Will be used to assume serviceX role.
output "agent_arn" {
  value = aws_iam_role.tfc_agent_task.arn
}

# Service A
output "ecs_init_serviceA_arn" {
  value = aws_iam_role.ecs_init_serviceA.arn
}

output "aws_ssm_param_serviceA_tfc_arn" {
  value = aws_ssm_parameter.serviceA_agent_token.arn
}
output "serviceA_agentpool_id" {
  value = tfe_agent_pool.ecs-agent-pool-serviceA.id
}

# Service B
output "ecs_init_serviceB_arn" {
  value = aws_iam_role.ecs_init_serviceB.arn
}
output "aws_ssm_param_serviceB_tfc_arn" {
  value = aws_ssm_parameter.serviceB_agent_token.arn
}
output "serviceB_agentpool_id" {
  value = tfe_agent_pool.ecs-agent-pool-serviceB.id
}