# Terraform + provider version constraints (Step 3: K8s cluster with Terraform)
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.8"
    }
  }
}
