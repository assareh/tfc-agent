output "agent_arn" {
  value = aws_iam_role.tfc_agent_task.arn
}
output "ecs_init_serviceB_id" {
  value = aws_iam_role.ecs_init_serviceB.id
}
output "agent_id" {
  value = aws_iam_role.tfc_agent_task.id
}

output "ecs_init_serviceB_arn" {
  value = aws_iam_role.ecs_init_serviceB.arn
}
output "ecs_init_serviceA_arn" {
  value = aws_iam_role.ecs_init_serviceA.arn
}

output "aws_ssm_param_serviceB_tfc_arn" {
  value = aws_ssm_parameter.agent_token.arn
}
output "aws_ssm_param_serviceA_tfc_arn" {
  value = aws_ssm_parameter.serviceA_agent_token.arn
}