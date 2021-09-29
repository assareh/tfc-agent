#output "team1_agent_token" {
#  value = tfe_agent_token.team1-agent-token.token
#}

output "gke_service_account_email" {
  value = google_service_account.gke.email
}

output "team_service_account_email" {
    value = { for t in sort(keys(local.iam_teams)) :
        t => {"gsa":module.iam-team-setup[t].team_gsa}
    }
}

output "agentpool_id" {
    value = { for t in sort(keys(local.iam_teams)) :
        t => {"agentpool":module.iam-team-setup[t].agentpool_id}
    }
}

output "team_iam_config" {
    value = {
        for team, configs in local.iam_teams: team => merge(
            configs, {"pool":module.iam-team-setup[team].agentpool_id}
        )
    }
}