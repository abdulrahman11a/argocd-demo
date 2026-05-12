resource "argocd_application" "myapp_dev" {
  metadata {
    name      = "myapp-dev"
    namespace = "argocd"
  }

  spec {
    project = "default"

    source {
      repo_url        = "https://github.com/YOUR_USERNAME/argocd-demo"
      target_revision = "main"
      path            = "overlays/dev"
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "dev"
    }

    sync_policy {
      automated {
        prune       = true
        self_heal   = true
        allow_empty = false
      }
      sync_options = ["CreateNamespace=true", "PruneLast=true"]
    }
  }
}

resource "argocd_application" "myapp_production" {
  metadata {
    name      = "myapp-production"
    namespace = "argocd"
  }

  spec {
    project = "default"

    source {
      repo_url        = "https://github.com/YOUR_USERNAME/argocd-demo"
      target_revision = "main"
      path            = "overlays/production"
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "production"
    }

    sync_policy {
      automated {
        prune     = true
        self_heal = true
      }
      sync_options = [
        "CreateNamespace=true",
        "PruneLast=true",
        "FailOnSharedResource=true"
      ]
    }
  }
}
