# Same structure, tuned for prod
locals {
  environment = "prod"
}

# Re‑use the same modules; only the local.env changes.
module "project_services" { source = "terraform-google-modules/project-factory/google//modules/project_services" version = "~> 15.0" project_id = var.project_id activate_apis = [
  "container.googleapis.com",
  "compute.googleapis.com",
  "iam.googleapis.com",
  "cloudresourcemanager.googleapis.com",
  "storage.googleapis.com",
  "logging.googleapis.com",
  "monitoring.googleapis.com",
] }

module "vpc" { 
    source = "terraform-google-modules/network/google" 
    version = "~> 9.0" 
    project_id = var.project_id 
    network_name = "${local.environment}-gke-network" 
    subnets = [{ subnet_name = "${local.environment}-subnet" subnet_ip = var.network_cidr subnet_region = var.region subnet_private_access = true subnet_flow_logs = true }] 
    secondary_ranges = { "${local.environment}-subnet" = [ { range_name = "pods" ip_cidr_range = "10.64.0.0/14" }, { range_name = "services" ip_cidr_range = "10.68.0.0/20" } ] } 
}

module "gke" { 
    source = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-private-cluster" 
    version = "~> 30.0" 
    project_id = var.project_id 
    name = "${local.environment}-autopilot" 
    region = var.region 
    release_channel = "stable" 
    network = module.vpc.network_name 
    subnetwork = module.vpc.subnets_names[0] 
    ip_range_pods = "pods" 
    ip_range_services = "services" 
    enable_autopilot = true 
    enable_private_nodes = true 
    enable_private_endpoint = false 
    master_ipv4_cidr_block = var.master_ipv4_cidr_block 
    remove_default_node_pool = true 
    cost_management_config = { enabled = true } 
}