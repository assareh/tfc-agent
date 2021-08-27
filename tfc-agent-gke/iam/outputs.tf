output "gcp_project" {
  value = data.google_project.project.id
}

output "serviceA_agentpool_id" {
  value = tfe_agent_pool.pool-serviceA.id
}
