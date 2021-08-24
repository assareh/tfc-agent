# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.gcp_region}-${var.prefix}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.gcp_region}-${var.prefix}-subnet"
  region        = var.gcp_region
  network       = google_compute_network.vpc.name
  ip_cidr_range = var.ip_cidr_range

}

