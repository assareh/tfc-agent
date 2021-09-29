terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "unity-pov" 

    workspaces {
      name = "gke_cluster"
    }
  }
}
