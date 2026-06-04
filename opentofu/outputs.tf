output "cluster_name" {
  description = "The name of the GKE cluster."
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "The endpoint of the GKE cluster."
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "kubeconfig" {
  description = "Helper Kubeconfig command."
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${var.region} --project ${var.project_id}"
}

output "artifact_registry_id" {
  description = "The ID of the Artifact Registry repository."
  value       = google_artifact_registry_repository.registry.id
}

output "gke_nodes_service_account_email" {
  description = "The email of the custom GKE node service account."
  value       = google_service_account.gke_nodes.email
}

