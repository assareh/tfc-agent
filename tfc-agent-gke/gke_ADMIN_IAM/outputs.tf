#output "team1_agent_token" {
#  value = tfe_agent_token.team1-agent-token.token
#}

output "gke_service_account_email" {
  value = google_service_account.gke.email
}

output "agentpool_id" {
    value = { for t in sort(keys(var.iam_teams)) :
        t => {"agentpool":module.iam-team-setup[t].agentpool_id}
    }
}

output "agentpool_token" {
    value = { for t in sort(keys(var.iam_teams)) :
        t => {"agent_token" : module.iam-team-setup[t].agent_token}
    }
}

output "team_iam_config" {
    value = {
        for team, configs in var.iam_teams: team => merge(
            configs, {"pool":module.iam-team-setup[team].agentpool_id}
        )
    }
}