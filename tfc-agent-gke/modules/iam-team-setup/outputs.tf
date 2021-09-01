output "gcp_project" {
  value = data.google_project.project.id
}

output "agentpool_id" {
  value = tfe_agent_pool.team-pool.id
}
output "agentpool_ids" {
  value = tomap({
    for k, id in tfe_agent_pool.team-pool.id : k => team-pool.name
  })
}

output "agent_token" {
  value = tfe_agent_token.team-agent-token.token
}