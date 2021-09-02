
#output "team1_agentpool_id" {
##  value = tfe_agent_pool.pool-team1.id
#}

#output "team1_agent_token" {
#  value = tfe_agent_token.team1-agent-token.token
#}

output "team_agentpool_ids" {
    value = { for t in sort(keys(var.iam_teams)) :
        t => module.iam-team-setup[t].agentpool_id
    }
}

output "teams" {
    value = { 
        flatten([for team, value in var.team:
                  {
                  "name" = value.name
                  "roles" = value.roles
                  "gsa" = value.gsa
                  "k8s_sa" = value.k8s_sa
                  "namespace" = value.namespace
                  "agentpool_id" = module.iam-team-setup[var.team].agentpool_id}
                ])
    }
}