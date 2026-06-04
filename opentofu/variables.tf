variable "project_id" {
  description = "The GCP Project ID where the GKE cluster will be created."
  type        = string
  default     = "terraform-460705"
}

variable "region" {
  description = "The GCP region to deploy the resources."
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "The name of the GKE cluster."
  type        = string
  default     = "devsecops-gke-cluster"
}

variable "network_name" {
  description = "The VPC network name."
  type        = string
  default     = "devsecops-vpc"
}

variable "subnet_name" {
  description = "The VPC subnetwork name."
  type        = string
  default     = "devsecops-subnet"
}

variable "node_count" {
  description = "Initial node count per zone."
  type        = number
  default     = 1
}

variable "machine_type" {
  description = "Machine type for cluster nodes. Using Spot VMs of this type."
  type        = string
  default     = "e2-standard-4"
}
