output "gcp_project" {
  value = data.google_project.project.id
}

output "agentpool_id" {
  value = tfe_agent_pool.pool-team1.id
}

output "agent_token" {
  value = tfe_agent_token.team1-agent-token.token
}