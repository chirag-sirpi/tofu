# ============================================================================
# vault-kms.tf — GCP KMS keyring + key + IAM for Vault auto-unseal
# Provision with: tofu apply -target=google_kms_key_ring.vault_unseal
# ============================================================================

# KMS keyring for Vault auto-unseal
resource "google_kms_key_ring" "vault_unseal" {
  name     = "vault-unseal-keyring"
  location = var.region
  project  = var.project_id
}

# Crypto key used by Vault gcpckms seal stanza
resource "google_kms_crypto_key" "vault_unseal" {
  name            = "vault-unseal-key"
  key_ring        = google_kms_key_ring.vault_unseal.id
  rotation_period = "7776000s" # 90-day automatic key rotation
  purpose         = "ENCRYPT_DECRYPT"

  lifecycle {
    prevent_destroy = true # Never delete the unseal key
  }
}

# GCP Service Account for Vault → KMS access via Workload Identity
resource "google_service_account" "vault_kms" {
  account_id   = "vault-kms-sa"
  display_name = "Vault KMS Auto-Unseal SA"
  project      = var.project_id
}

# Grant Vault SA permission to use the KMS key for encrypt/decrypt
resource "google_kms_crypto_key_iam_member" "vault_unseal_encrypter" {
  crypto_key_id = google_kms_crypto_key.vault_unseal.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.vault_kms.email}"
}

# Workload Identity binding: vault k8s SA → GCP SA
resource "google_service_account_iam_member" "vault_workload_identity" {
  service_account_id = google_service_account.vault_kms.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[vault/vault]"
}

output "vault_kms_keyring" {
  value       = google_kms_key_ring.vault_unseal.name
  description = "KMS keyring name for Vault auto-unseal"
}

output "vault_kms_key" {
  value       = google_kms_crypto_key.vault_unseal.name
  description = "KMS crypto key name for Vault auto-unseal"
}

output "vault_kms_sa_email" {
  value       = google_service_account.vault_kms.email
  description = "GCP SA email — annotate vault k8s ServiceAccount with this"
}
