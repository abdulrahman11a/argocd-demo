# Troubleshooting Guide

## Common Issues

### 1. Minikube not starting

```bash
minikube delete
minikube start --memory=4096 --cpus=2 --driver=docker
```

### 2. Argo CD pods not ready

```bash
kubectl get pods -n argocd
kubectl describe pod <pod-name> -n argocd
kubectl logs <pod-name> -n argocd
```

### 3. Port 8080 already in use

```bash
sudo fuser -k 8080/tcp
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### 4. App OutOfSync

```bash
# Check what's different
argocd app diff myapp

# Force sync
argocd app sync myapp --force

# Check logs
argocd app logs myapp
```

### 5. ComparisonError / DNS timeout

```bash
# Restart repo server
kubectl rollout restart deployment argocd-repo-server -n argocd

# Check DNS
kubectl get pods -n kube-system | grep coredns
```

### 6. Image pull errors

```bash
# Check the secret
kubectl get secret docker-hub-secret -n default

# Recreate it
kubectl create secret docker-registry docker-hub-secret \
  --docker-username=USER \
  --docker-password=PASS \
  -n default
```

### 7. Terraform state lock

```bash
# Force unlock (DynamoDB)
terraform force-unlock <lock-id>
```

## Useful Commands

```bash
# Full status check
kubectl get all -n argocd
kubectl get applications -n argocd

# Watch sync
argocd app get myapp --watch

# Get events
kubectl get events -n argocd --sort-by='.lastTimestamp'

# Refresh app manually
argocd app get myapp --refresh
```
