#k8s cluster account
resource "google_service_account" "cluster-serviceaccount" {
  account_id   = "cluster-serviceaccount"
  display_name = "Service Account For Terraform To Make GKE Cluster"
}

# service account
resource "google_service_account" "workload-identity-user-sa" {
  account_id   = "workload-identity-tutorial"
  display_name = "Service Account For Workload Identity"
}
resource "google_project_iam_member" "storage-role" {
  role = "roles/storage.admin"
  # role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.workload-identity-user-sa.email}"
}
resource "google_project_iam_member" "workload_identity-role" {
  role   = "roles/iam.workloadIdentityUser"
  member = "serviceAccount:${var.gcp_project}.svc.id.goog[tfc-agent/servicea-dev-deploy-servicea]"
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

resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
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
    #service_account = google_service_account.default.email
    #oauth_scopes = [
    #  "https://www.googleapis.com/auth/logging.write",
    #  "https://www.googleapis.com/auth/monitoring",
    #  "https://www.googleapis.com/auth/cloud-platform"
    #]
    service_account = google_service_account.cluster-serviceaccount.email
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

