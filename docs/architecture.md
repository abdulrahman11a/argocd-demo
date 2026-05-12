# Architecture

## Overview
Developer → Git Push → GitHub
↓
GitHub Actions (CI)
├── Test
├── Build Docker Image
├── Push to Docker Hub
└── Update image tag in manifests
↓
Git Commit
↓
Argo CD (watches Git)
↓
kubectl apply
↓
Kubernetes Cluster

## Components

| Component | Role |
|-----------|------|
| GitHub | Source of truth for code + manifests |
| GitHub Actions | CI — build, test, push |
| Docker Hub | Image registry |
| Argo CD | CD — sync Git to cluster |
| Kubernetes | Runtime environment |
| Minikube | Local cluster (dev) |

## Repo Structure
argocd-demo/
├── apps/        ← Argo CD Application definitions
├── base/        ← Base K8s manifests
├── overlays/    ← Per-environment customizations
├── bootstrap/   ← Argo CD install + root app
├── terraform/   ← Infrastructure as Code
├── helm/        ← Helm charts
├── scripts/     ← Helper scripts
└── docs/        ← Documentation
