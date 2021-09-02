#output "team1_agent_token" {
#  value = tfe_agent_token.team1-agent-token.token
#}

output "gke_service_account_email" {
  value = google_service_account.gke.email
}

output "team_agent_tokens" {
    value = { for t in sort(keys(var.iam_teams)) :
        t => {"token":module.iam-team-setup[t].agent_token}
    }
    sensitive = true
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
    value = {
        for team, configs in var.iam_teams: team => merge(
            configs, {"pool":module.iam-team-setup[team].agentpool_id}
        )
    }
}