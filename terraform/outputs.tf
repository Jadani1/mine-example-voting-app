output "cluster_name" {
  description = "Name of the Kind cluster"
  value       = kind_cluster.voting.name
}

output "kubeconfig_path" {
  description = "Path to the kubeconfig written by the Kind provider"
  value       = kind_cluster.voting.kubeconfig_path
}

output "client_certificate" {
  description = "Client certificate for cluster auth (sensitive)"
  value       = kind_cluster.voting.client_certificate
  sensitive   = true
}

output "endpoint" {
  description = "Kubernetes API server endpoint"
  value       = kind_cluster.voting.endpoint
}

output "vote_url" {
  description = "Vote UI on the host after deploying k8s-specifications"
  value       = "http://localhost:${var.vote_host_port}"
}

output "result_url" {
  description = "Result UI on the host after deploying k8s-specifications"
  value       = "http://localhost:${var.result_host_port}"
}
