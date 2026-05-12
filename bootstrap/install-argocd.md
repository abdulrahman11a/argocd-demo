# Installing Argo CD

## Prerequisites
- kubectl configured
- cluster running

## Install

```bash
kubectl create namespace argocd

kubectl apply -n argocd -f \
  https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s
```

## Get Admin Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d; echo
```

## Access UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# https://localhost:8080
# user: admin
```
