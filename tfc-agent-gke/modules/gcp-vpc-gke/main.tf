# GKE cluster
resource "google_container_cluster" "primary" {
  name     = var.prefix
  #location = var.gcp_region
  location   = var.gcp_zone

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  master_auth {
    username = var.gke_username
    password = var.gke_password

    client_certificate_config {
      issue_client_certificate = true
    }
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}-npool"
  #location = var.gcp_region
  location   = var.gcp_zone
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      env = var.prefix
      region = var.gcp_region
    }

    # preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", var.prefix]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

