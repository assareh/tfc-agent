
#output "team1_agentpool_id" {
##  value = tfe_agent_pool.pool-team1.id
#}

#output "team1_agent_token" {
#  value = tfe_agent_token.team1-agent-token.token
#}

output "team_agentpool_ids" {
    value = { for t in sort(keys(var.iam_teams)) :
        t => {"agentpool":module.iam-team-setup[t].agentpool_id}
    }
}

output "teams" {
    value = flatten([for t in var.iam_teams :
                  {
                  "name" = t.name
                  "roles" = t.roles
                  "gsa" = t.gsa
                  "k8s_sa" = t.k8s_sa
                  "namespace" = t.namespace}
                ])
}
output "teams2" {
    value = merge(
        {for t in sort(keys(var.iam_teams)):
            t => var.iam_teams[t]},
        {for id in sort(keys(var.iam_teams)):
            id => {"pool":module.iam-team-setup[id].agentpool_id}}

    )
}
output "keys" {
    value = { for t in sort(keys(var.iam_teams)) :
    t => var.iam_teams[t]
    }
}