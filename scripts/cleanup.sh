#!/bin/bash
set -e

echo "======================================"
echo "  Cleanup Script"
echo "======================================"

read -p "Are you sure? This deletes everything! (yes/no): " CONFIRM
[ "$CONFIRM" != "yes" ] && echo "Cancelled." && exit 0

echo "Deleting all Argo CD applications..."
kubectl delete applications --all -n argocd 2>/dev/null || true

echo "Deleting Argo CD namespace..."
kubectl delete namespace argocd 2>/dev/null || true

echo "Deleting app namespaces..."
kubectl delete namespace dev staging production 2>/dev/null || true

echo "Stopping Minikube..."
minikube stop 2>/dev/null || true

echo "Done! Cleanup complete."
