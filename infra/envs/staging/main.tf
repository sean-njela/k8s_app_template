###############################################################
#  STAGING – GKE Autopilot (private, regional, stable channel)
###############################################################

locals {
  environment = "staging"
}

###############################
# Enable required Google APIs
###############################
module "project_services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 15.0"

  project_id    = var.project_id
  activate_apis = [
    "container.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "storage.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ]
}

###############################
# VPC + subnet + secondary CIDRs
###############################
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.0"

  project_id   = var.project_id
  network_name = "${local.environment}-gke-network"

  subnets = [{
    subnet_name           = "${local.environment}-subnet"
    subnet_ip             = var.network_cidr
    subnet_region         = var.region
    subnet_private_access = true
    subnet_flow_logs      = true
  }]

  secondary_ranges = {
    "${local.environment}-subnet" = [
      {
        range_name    = "pods"
        ip_cidr_range = "10.48.0.0/14"
      },
      {
        range_name    = "services"
        ip_cidr_range = "10.52.0.0/20"
      }
    ]
  }
}

#############################################
# GKE Autopilot (private endpoint disabled)
#############################################
module "gke" {
  # Private‑cluster variant with Autopilot support
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-private-cluster"
  version = "~> 30.0"

  project_id               = var.project_id
  name                     = "${local.environment}-autopilot"
  region                   = var.region
  release_channel          = "stable"

  network                  = module.vpc.network_name
  subnetwork               = module.vpc.subnets_names[0]
  ip_range_pods            = "pods"
  ip_range_services        = "services"

  enable_autopilot         = true  # 🚀 Hands‑off node management
  enable_private_nodes     = true
  enable_private_endpoint  = false # public master endpoint ➜ easier kubectl access
  master_ipv4_cidr_block   = var.master_ipv4_cidr_block
  remove_default_node_pool = true  # Autopilot ignores node pools anyway

  ## Optional: Turn on cost‑optimised features
  cost_management_config = {
    enabled = true
  }
}