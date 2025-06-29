output "cluster_name" {
  description = "GKE Autopilot cluster name"
  value       = module.gke.name
}

output "cluster_endpoint" {
  description = "Public endpoint to reach the cluster API server"
  value       = module.gke.endpoint
}

output "kubernetes_version" {
  description = "Exact Kubernetes version deployed by Autopilot"
  value       = module.gke.cluster_version
}