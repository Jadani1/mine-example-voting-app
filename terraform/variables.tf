variable "cluster_name" {
  description = "Name of the Kind Kubernetes cluster"
  type        = string
  default     = "voting-app"
}

variable "node_image" {
  description = "Kind node image (Kubernetes version). See https://github.com/kubernetes-sigs/kind/releases"
  type        = string
  default     = "kindest/node:v1.31.2"
}

variable "vote_host_port" {
  description = "Host port mapped to vote Service NodePort 31000"
  type        = number
  default     = 8080
}

variable "result_host_port" {
  description = "Host port mapped to result Service NodePort 31001"
  type        = number
  default     = 8081
}
