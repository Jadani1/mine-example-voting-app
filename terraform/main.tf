# =============================================================================
# Example Voting App — Kind Kubernetes cluster (Terraform)
# =============================================================================
# Provisions a local Kind cluster you can create, destroy, and recreate from code.
#
# Prerequisites:
#   - Docker Desktop running
#   - Kind CLI optional (provider talks to Docker; kind binary helps debugging)
#   - Terraform >= 1.5
#
# Usage:
#   cd terraform
#   terraform init
#   terraform plan
#   terraform apply -auto-approve
#   terraform destroy -auto-approve
# =============================================================================

provider "kind" {}

resource "kind_cluster" "voting" {
  name           = var.cluster_name
  wait_for_ready = true

  # Pin a Kind node image for reproducible clusters (override via variables).
  node_image = var.node_image

  # Stable path so kubectl can use: export KUBECONFIG=$PWD/kubeconfig
  kubeconfig_path = pathexpand("${path.module}/kubeconfig")

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    # Single control-plane node is enough for the voting app capstone.
    node {
      role = "control-plane"

      # Expose app NodePorts on the host (see k8s-specifications/*-service.yaml):
      #   vote   NodePort 31000 → http://localhost:8080
      #   result NodePort 31001 → http://localhost:8081
      extra_port_mappings {
        container_port = 31000
        host_port      = var.vote_host_port
        protocol       = "TCP"
      }

      extra_port_mappings {
        container_port = 31001
        host_port      = var.result_host_port
        protocol       = "TCP"
      }
    }
  }
}
