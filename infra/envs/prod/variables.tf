variable "project_id" {
  description = "GCP project ID for this environment"
  type        = string
}

variable "region" {
  description = "GCP region to deploy resources (Autopilot is regional only)"
  type        = string
  default     = "europe-central2"
}

variable "network_cidr" {
  description = "Primary CIDR block for the VPC subnet"
  type        = string
  default     = "10.0.0.0/18"
}

variable "master_ipv4_cidr_block" {
  description = "/28 block for the GKE control‑plane master"
  type        = string
  default     = "172.16.0.0/28"
}