locals {
  gke_service_account_email = var.gke_service_account_email != "" ? var.gke_service_account_email : "compute@developer.gserviceaccount.com"
}

# GKE cluster
resource "google_container_cluster" "primary" {
  name     = var.prefix
  project  = var.gcp_project
  #location = var.gcp_region
  location   = var.gcp_zone
  min_master_version = var.cluster_version

  lifecycle {
    ignore_changes = [
      # Ignore changes to min-master-version as that gets changed
      # after deployment to minimum precise version Google has
      min_master_version,
    ]
  }

  remove_default_node_pool = true
  initial_node_count       = 1
  workload_identity_config {
    identity_namespace = "${var.gcp_project}.svc.id.goog"
  }
  
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
  project = var.gcp_project
  location   = var.gcp_zone
  cluster    = google_container_cluster.primary.name
  version = var.cluster_version

  node_count = var.gke_num_nodes
  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }
  node_config {
    service_account = local.gke_service_account_email
    oauth_scopes = [
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
  lifecycle {
    ignore_changes = [
      # Ignore changes to node_count, initial_node_count and version
      # otherwise node pool will be recreated if there is drift between what 
      # terraform expects and what it sees
      initial_node_count,
      node_count,
      version
    ]
  }
}

