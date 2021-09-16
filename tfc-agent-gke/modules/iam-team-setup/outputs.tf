output "gcp_project" {
  value = data.google_project.project.id
}

output "agentpool_id" {
  value = tfe_agent_pool.team_pool.id
}

output "agent_token" {
  value = tfe_agent_token.team_agent_token.token
}

output "team" {
  value = var.team
}