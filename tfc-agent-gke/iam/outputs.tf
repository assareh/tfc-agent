output "gcp_project" {
  value = data.google_project.project.id
}

output "instance_names" {
  value = google_compute_instance.tfc-agent.*.name
}

output "terraform-dev-role" {
  value = google_service_account.terraform-dev-role.email
}

output "tfc-agent-sa" {
  value = google_service_account.tfc-agent.email
}
