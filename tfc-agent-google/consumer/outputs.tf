output "external_ip" {
  value = google_compute_instance.this.network_interface.0.access_config.0.nat_ip
}

output "instance_name" {
  value = google_compute_instance.this.name
}

output "source-email" {
  value = data.google_client_openid_userinfo.source.email
}

output "target-email" {
  value = data.google_client_openid_userinfo.target.email
}
