provider "google" {
  #credentials = file(var.account_file_path)
  project     = var.gcloud-project
  region      = var.gcloud-region
}

#resource "google_service_account" "vault_kms_service_account" {
#  account_id   = "vault-gcpkms"
#  display_name = "Vault KMS for auto-unseal"
#}

# Create a KMS key ring
resource "google_kms_key_ring" "key_ring" {
  project  = var.gcloud-project
  name     = var.key_ring
  location = var.keyring_location
}

# Create a crypto key for the key ring
resource "google_kms_crypto_key" "crypto_key" {
  name            = var.crypto_key
  key_ring        = google_kms_key_ring.key_ring.self_link
  rotation_period = "100000s"
}

# Add the service account to the Keyring
#resource "google_kms_key_ring_iam_binding" "vault_iam_kms_binding" {
#  key_ring_id = "${google_kms_key_ring.key_ring.id}"
#  #key_ring_id = "${var.gcloud-project}/${var.keyring_location}/${var.key_ring}"
#  role = "roles/owner"#
#
#  members = [
#    "serviceAccount:${google_service_account.vault_kms_service_account.email}",
#  ]
#}
