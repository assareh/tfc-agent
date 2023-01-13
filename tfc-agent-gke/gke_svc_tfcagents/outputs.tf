output "gke_sa" {
    value = { for t in sort(keys(local.teams)) :
        t => {"gke_sa":module.tfc_agent[t].gke_deployment}
    }
}