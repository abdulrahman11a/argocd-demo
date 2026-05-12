# argocd-demo

GitOps demo repository — Argo CD + Kubernetes + Terraform

## Quick Start

```bash
# 1. Setup everything
./scripts/install.sh

# 2. Apply root app (App of Apps)
kubectl apply -f bootstrap/root-app.yaml

# 3. Open UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
# https://localhost:8080
```

## Structure

| Folder | Purpose |
|--------|---------|
| `apps/` | Argo CD Application YAMLs |
| `base/` | Base Kubernetes manifests |
| `overlays/` | Per-environment patches |
| `bootstrap/` | Argo CD install |
| `terraform/` | Infrastructure as Code |
| `helm/` | Helm charts |
| `scripts/` | Helper scripts |
| `docs/` | Documentation |

## Environments

| Env | Namespace | Replicas | Auto-sync |
|-----|-----------|----------|-----------|
| dev | dev | 1 | ✅ |
| staging | staging | 2 | ✅ |
| production | production | 5 | ✅ + manual gate |
