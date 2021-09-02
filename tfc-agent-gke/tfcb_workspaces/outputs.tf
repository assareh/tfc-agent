#output "team1_agent_token" {
#  value = tfe_agent_token.team1-agent-token.token
#}

output "team_agentpool_ids" {
    value = { for t in sort(keys(var.iam_teams)) :
        t => {"agentpool":module.iam-team-setup[t].agentpool_id}
    }
}

output "team_config" {
    value = merge(
        {for t in sort(keys(var.iam_teams)):
            t => var.iam_teams[t]},
        {for t in sort(keys(var.iam_teams)):
            t => {"pool":module.iam-team-setup[t].agentpool_id}}

    )
}