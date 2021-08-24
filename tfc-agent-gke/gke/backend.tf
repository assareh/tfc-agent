terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "presto-projects"

    workspaces {
      name = "gke_cluster"
    }
  }
}