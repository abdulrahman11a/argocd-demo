variable "kube_context" {
  description = "Kubernetes context to use"
  type        = string
  default     = "minikube"
}

variable "argocd_server" {
  description = "Argo CD server address"
  type        = string
  default     = "localhost:8080"
}

variable "argocd_username" {
  description = "Argo CD admin username"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "argocd_password" {
  description = "Argo CD admin password"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Must be: dev, staging, or production."
  }
}

variable "replicas" {
  description = "Number of replicas"
  type        = number
  default     = 2
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}
