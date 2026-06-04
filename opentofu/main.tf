terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC Network
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/16"

  secondary_ip_range {
    range_name    = "k8s-pod-range"
    ip_cidr_range = "10.48.0.0/14"
  }

  secondary_ip_range {
    range_name    = "k8s-service-range"
    ip_cidr_range = "10.52.0.0/20"
  }
}

# GKE Cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region

  # We can't define a cluster with no node pool, so we create a small default one and delete it immediately.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  ip_allocation_policy {
    cluster_secondary_range_name  = "k8s-pod-range"
    services_secondary_range_name = "k8s-service-range"
  }

  # Add release channel configuration
  release_channel {
    channel = "REGULAR"
  }

  # Enable network policy for security rules
  network_policy {
    enabled = true
  }

  # Ensure the cluster has workload identity enabled for secure IAM integrations
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Force the temporary default node pool to also use smaller standard HDD disk
  node_config {
    disk_size_gb = 30
    disk_type    = "pd-standard"
  }
}

# Separated Node Pool using SPOT VMs for low-cost ($1.50-$2.00/day) dev environment
resource "google_container_node_pool" "spot_nodes" {
  name       = "spot-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  node_config {
    # SPOT instances are much cheaper and ideal for this project.
    spot         = true
    machine_type = var.machine_type

    # Use standard HDD disks to stay within quotas
    disk_size_gb = 30
    disk_type    = "pd-standard"

    # Configure custom service account with least-privilege permissions
    service_account = google_service_account.gke_nodes.email

    # Enable metadata server for workload identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    # IAM scopes for standard operations
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append"
    ]

    labels = {
      env = "devsecops-env"
    }

    tags = ["gke-node", "devsecops-cluster"]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

# Artifact Registry for container images
resource "google_artifact_registry_repository" "registry" {
  location      = var.region
  repository_id = "devsecops-repo"
  description   = "Docker repository for DevSecOps application images"
  format        = "DOCKER"
}

# GKE Node Service Account with least privilege
resource "google_service_account" "gke_nodes" {
  account_id   = "gke-node-sa"
  display_name = "GKE Node Service Account"
}

# IAM role bindings for the custom service account to allow logging, monitoring, and registry pull
resource "google_project_iam_member" "gke_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_monitoring_viewer" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_registry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

