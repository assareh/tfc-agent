terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "presto-projects"

    workspaces {
      name = "gcp_gke_tfcagents"
    }
  }
}