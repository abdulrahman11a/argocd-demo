output "argocd_namespace" {
  description = "Argo CD namespace"
  value       = "argocd"
}

output "argocd_server_url" {
  description = "Argo CD server URL"
  value       = "https://${var.argocd_server}"
}

output "namespaces_created" {
  description = "Created namespaces"
  value       = [for ns in kubernetes_namespace.environments : ns.metadata[0].name]
}

output "helm_release_status" {
  description = "Argo CD Helm release status"
  value       = helm_release.argocd.status
}
