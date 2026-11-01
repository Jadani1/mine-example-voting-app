# Terraform — Kind Kubernetes cluster (Step 3)

Infrastructure-as-code for a **local Kind** cluster used by the Example Voting App.

Application manifests stay in `../k8s-specifications/`. This folder only provisions the cluster.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop) running
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- [kubectl](https://kubernetes.io/docs/tasks/tools/) (to verify the cluster)

## Files

| File | Purpose |
|------|---------|
| `versions.tf` | Terraform + `tehcyx/kind` provider constraints |
| `main.tf` | `kind_cluster` with NodePort host mappings |
| `variables.tf` | Cluster name, node image, host ports |
| `outputs.tf` | Cluster name, kubeconfig path, app URLs |

Host port mappings match the existing Services:

- vote → NodePort **31000** → `localhost:8080`
- result → NodePort **31001** → `localhost:8081`

## Create the cluster

```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

## Test the cluster

```bash
# Point kubectl at the cluster (path also printed by terraform output)
export KUBECONFIG="$(terraform output -raw kubeconfig_path)"   # Git Bash / macOS / Linux
# PowerShell: $env:KUBECONFIG = terraform output -raw kubeconfig_path

kubectl cluster-info
kubectl get nodes
```

Deploy the app (after images are available to the cluster):

```bash
kubectl apply -f ../k8s-specifications/
kubectl get pods,svc
```

## Destroy and recreate cleanly (capstone requirement)

```bash
# Tear down
terraform destroy -auto-approve

# Recreate from code only
terraform apply -auto-approve
kubectl get nodes
```

## Optional overrides

```bash
terraform apply -var="cluster_name=my-voting" -var="vote_host_port=8080"
```

Or copy `terraform.tfvars.example` → `terraform.tfvars` (gitignored).
