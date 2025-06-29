terraform {
  required_version = ">= 1.8.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      # Tested with 5.27.x (2025‑06) – adjust to latest stable
      version = "~> 5.27"
    }
  }
}

provider "google" {
  project = var.project_id      # e.g. "my-solo-dev-123"
  region  = var.region          # e.g. "europe-central2"
}