#output "team1_agent_token" {
#  value = tfe_agent_token.team1-agent-token.token
#}

output "gke_service_account_email" {
  value = google_service_account.gke.email
}

output "team_agentpool_ids" {
    value = { for t in sort(keys(var.iam_teams)) :
        t => {"agentpool":module.iam-team-setup[t].agentpool_id}
    }
}

output "team_config" {
    value = {for t in sort(keys(var.iam_teams)):
            t => var.iam_teams[t]}
}
output "team_config_all" {
    value = merge(
        {for t in sort(keys(var.iam_teams)):
            t => var.iam_teams[t]},
        {for team in sort(keys(var.iam_teams)):
            team => {"pool":module.iam-team-setup[team].agentpool_id}}

    )
}