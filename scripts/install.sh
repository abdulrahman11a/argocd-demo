#!/bin/bash
set -e

echo "======================================"
echo "  Argo CD + GitOps Setup Script"
echo "======================================"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()  { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Check dependencies
command -v kubectl &>/dev/null || err "kubectl not found"
command -v git     &>/dev/null || err "git not found"

log "Starting Minikube..."
minikube start --memory=4096 --cpus=2 || warn "Minikube already running"

log "Creating argocd namespace..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

log "Installing Argo CD..."
kubectl apply -n argocd -f \
  https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

log "Waiting for Argo CD pods..."
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

log "Getting admin password..."
PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "======================================"
echo "  Argo CD Ready!"
echo "======================================"
echo "  URL:      https://localhost:8080"
echo "  Username: admin"
echo "  Password: $PASSWORD"
echo "======================================"
echo ""
echo "Run to access UI:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
