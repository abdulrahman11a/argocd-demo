# 🐙 ArgoCD Demo — GitOps with Kubernetes

A hands-on demo project showcasing **GitOps** continuous delivery using **ArgoCD** on a local Kubernetes cluster (Minikube).

---

## 📐 Architecture


<img width="5027" height="2620" alt="argo" src="https://github.com/user-attachments/assets/64a9c013-89c7-4be4-8081-59da90b16fec" />



ArgoCD **polls** the Git repository, detects any changes, and automatically **synchronises** the desired state into the Kubernetes cluster.

---

## 🚀 Getting Started

### Prerequisites

| Tool | Version |
|------|---------|
| [Minikube](https://minikube.sigs.k8s.io/) | v1.30+ |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | v1.27+ |
| [ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/) | v2.x |

---

### 1. Start Minikube

```bash
minikube start --nodes=2
```

### 2. Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Wait for all pods to be ready:

```bash
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=120s
```

### 3. Access the ArgoCD UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Then open: [https://localhost:8080](https://localhost:8080)

Get the initial admin password:

```bash
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d
```

### 4. Deploy the Nginx App

```bash
kubectl apply -f application.yaml
```

---

## 📁 Project Structure

```
argocd-demo/
├── nginx/
│   ├── deployment.yaml   # Nginx Deployment (replicas, image, etc.)
│   └── service.yaml      # ClusterIP Service
├── application.yaml      # ArgoCD Application manifest
└── README.md
```

---

## ⚙️ GitOps Flow

1. **Push** a change to this repo (e.g. increase replicas)
2. **ArgoCD polls** the repo every 3 minutes (or trigger manually)
3. ArgoCD detects the **diff** between Git state and cluster state
4. ArgoCD **syncs** the new state to the cluster automatically

---

## 🔁 Example — Scale Nginx

Edit `nginx/deployment.yaml`:

```yaml
spec:
  replicas: 4   # changed from 3 to 4
```

Commit and push:

```bash
git add nginx/deployment.yaml
git commit -m "Increase Nginx replicas from 3 to 4"
git push origin main
```

ArgoCD will detect the change and apply it to the cluster within minutes.

---

## 🩺 Troubleshooting

| Issue | Fix |
|-------|-----|
| `DNS i/o timeout` on ArgoCD | Restart `argocd-application-controller` |
| App stuck in `Progressing` | Check pod events with `kubectl describe pod` |
| Can't access ArgoCD UI | Ensure port-forward is running |

```bash
# Restart application controller
kubectl rollout restart statefulset/argocd-application-controller -n argocd

# Check app status
kubectl get applications -n argocd
```

---

## 📚 References

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [GitOps Principles](https://opengitops.dev/)
- [Minikube Docs](https://minikube.sigs.k8s.io/docs/)

---
