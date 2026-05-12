# إنشاء الـ namespaces
resource "kubernetes_namespace" "environments" {
  for_each = toset(["dev", "staging", "production"])

  metadata {
    name = each.key
    labels = {
      managed-by  = "terraform"
      environment = each.key
    }
  }
}

# تنصيب Argo CD بـ Helm
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.51.0"
  namespace        = "argocd"
  create_namespace = true

  values = [
    file("${path.module}/argocd/helm.tf")
  ]

  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }
}
