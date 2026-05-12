<div align="center">
  <img src="https://argo-cd.readthedocs.io/en/stable/assets/logo.png" width="80px" />
  <h1>argocd-demo</h1>
  <p><strong>GitOps platform built with Argo CD · Kubernetes · Terraform · Helm</strong><br>
  Git is the single source of truth — never touch the cluster directly.</p>

  <!-- Badges -->
  ![Argo CD](https://img.shields.io/badge/Argo_CD-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)
  ![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
  ![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
  ![Helm](https://img.shields.io/badge/Helm-0F1689?style=for-the-badge&logo=helm&logoColor=white)
  ![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)
  ![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
  ![Minikube](https://img.shields.io/badge/Minikube-F7931E?style=for-the-badge&logo=kubernetes&logoColor=white)

</div>

<img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png">

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Repository Structure](#repository-structure)
- [File-by-File Breakdown](#file-by-file-breakdown)
- [Environments](#environments)
- [GitOps Flow](#gitops-flow)
- [Rollback](#rollback)
- [Tech Stack](#tech-stack)

<img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png">

## Overview

`argocd-demo` is a full GitOps reference implementation. It shows how to bootstrap Argo CD on a Kubernetes cluster, manage multi-environment deployments using Kustomize overlays, provision infrastructure with Terraform, and package applications with Helm — all driven by Git as the only source of truth.




<!-- 
  💡 OPTIONS FOR ADDING A VIDEO TO YOUR README:
  
  Option 1 — GIF (plays inline, best for short clips under 30s):
  Convert your screen recording to GIF, upload it to the repo or an image host, then use:
  
  ![Demo GIF](./docs/demo.gif)
  
  Option 2 — YouTube / Loom (click-to-watch, best for longer demos):
  Upload your video, then replace the button link above with your URL.
  You can also embed a thumbnail that links out:
  
  [![Demo Thumbnail](https://img.youtube.com/vi/YOUR_VIDEO_ID/maxresdefault.jpg)](https://youtu.be/YOUR_VIDEO_ID)
  
  Option 3 — GitHub-hosted MP4 (auto-plays in browser, no GIF needed):
  Drag-and-drop your .mp4 into a GitHub Issue or PR comment,
  copy the generated URL, then paste it here as a plain link or markdown image:
  
  https://github.com/user-attachments/assets/YOUR_VIDEO_HASH.mp4
  
  GitHub renders MP4 links as an inline player in README files automatically.
-->

<img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png">

## Architecture

<img width="1536" height="1024" alt="GitOps" src="https://github.com/user-attachments/assets/2bcc92f1-43d8-426c-82dc-d5713f1969b9" />

<img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png">

## Quick Start

```bash
# 1. Spin up the cluster and install Argo CD
./scripts/install.sh

# 2. Deploy the root "App of Apps"
kubectl apply -f bootstrap/root-app.yaml

# 3. Open the Argo CD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Visit: https://localhost:8080
# Username: admin
# Password: printed by install.sh
```

<img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png">

## Repository Structure

```
argocd-demo/
├── apps/               ← Argo CD Application definitions (one per environment)
├── base/               ← Base Kubernetes manifests (shared across all envs)
├── overlays/           ← Per-environment Kustomize patches
│   ├── dev/
│   ├── staging/
│   └── production/
├── bootstrap/          ← One-time Argo CD install + root App of Apps
├── terraform/          ← Infrastructure as Code
│   ├── argocd/         ← Argo CD-specific Terraform resources
│   └── environments/   ← Per-environment .tfvars files
├── helm/               ← Helm chart for the application
│   └── myapp/
│       └── templates/
├── scripts/            ← Helper shell scripts
├── docs/               ← Architecture and runbook documentation
├── .gitignore
└── README.md
```

---

## File-by-File Breakdown

<details>
<summary>📁 <strong>bootstrap/</strong> — One-time Argo CD install + App of Apps</summary>

<br>

#### `bootstrap/install-argocd.md`
Step-by-step guide to installing Argo CD manually. Covers:
- Creating the `argocd` namespace with `kubectl create namespace argocd`
- Applying the official Argo CD stable install manifest
- Waiting for all pods to become `Ready`
- Retrieving the initial admin password from the `argocd-initial-admin-secret` Kubernetes secret
- Port-forwarding to access the UI at `https://localhost:8080`

Use this file when you need to install Argo CD by hand instead of via Terraform.

---

#### `bootstrap/root-app.yaml`
Defines the **root Application** — the "App of Apps" pattern.

```yaml
# Key fields:
source.path: apps/       # Argo CD watches this folder
syncPolicy.automated:
  prune: true            # Removes resources deleted from Git
  selfHeal: true         # Re-applies if someone manually edits the cluster
```

Once applied, Argo CD reads everything inside `apps/` and creates child Applications automatically. Adding a new environment requires only dropping a new YAML file in `apps/` — no manual Argo CD UI interaction needed.

</details>

---

<details>
<summary>📁 <strong>terraform/</strong> — Infrastructure as Code</summary>

<br>

#### `terraform/providers.tf`
Declares the Terraform providers and remote backend:

- **hashicorp/kubernetes** — manages Kubernetes resources (namespaces, secrets)
- **hashicorp/helm** — installs Argo CD via Helm
- **oboukili/argocd** — creates Argo CD Application resources via its API
- **S3 backend** — stores `terraform.tfstate` remotely so the state is shared across team members and CI

---

#### `terraform/main.tf`
Core infrastructure resources:

- Creates the `dev`, `staging`, and `production` namespaces using `kubernetes_namespace`, each labeled `managed-by = terraform`
- Installs Argo CD using `helm_release` from the official `argo-helm` chart (version `5.51.0`)

---

#### `terraform/variables.tf`

| Variable          | Default          | Description                                       |
|-------------------|------------------|---------------------------------------------------|
| `kube_context`    | `minikube`       | The `kubectl` context to connect to               |
| `argocd_server`   | `localhost:8080` | Argo CD server address for the provider           |
| `argocd_username` | `admin`          | Argo CD login (marked sensitive)                  |
| `argocd_password` | —                | Argo CD password (marked sensitive, no default)   |
| `environment`     | `dev`            | Target environment; validated against allowed set |
| `replicas`        | `2`              | Number of pod replicas to deploy                  |

---

#### `terraform/outputs.tf`
Exports after `terraform apply`:

- `argocd_namespace` — always `"argocd"`
- `argocd_server_url` — the full HTTPS URL
- `namespaces_created` — list of namespace names Terraform created
- `helm_release_status` — status string (`deployed`, `failed`, etc.)

---

#### `terraform/argocd/namespace.tf`
Creates the dedicated `argocd` namespace with labels `managed-by = terraform` and `app = argocd`. Kept separate from `main.tf` so the Argo CD namespace can be managed and destroyed independently.

---

#### `terraform/argocd/helm.tf`
YAML values passed to the `helm_release` resource:

- Runs the server in `--insecure` mode (TLS handled at ingress)
- Sets `server.service.type: ClusterIP`
- Configures resource `requests` and `limits` for the repo-server and Redis

---

#### `terraform/argocd/applications.tf`
Creates Argo CD `Application` resources via the `argocd` Terraform provider:

- **`myapp-dev`** — auto-syncs from `overlays/dev`, pruning and self-healing enabled
- **`myapp-production`** — auto-syncs from `overlays/production` with `FailOnSharedResource=true`

---

#### `terraform/environments/dev.tfvars`
```hcl
environment  = "dev"
replicas     = 1          # Single replica, saves resources
image_tag    = "latest"
kube_context = "minikube"
```

#### `terraform/environments/prod.tfvars`
```hcl
environment  = "production"
replicas     = 5           # High availability
image_tag    = "v1.0.0"   # Pinned to a specific release tag
kube_context = "prod-cluster"
```

</details>

---

<details>
<summary>📁 <strong>helm/</strong> — Application Helm Chart</summary>

<br>

#### `helm/myapp/Chart.yaml`
- Chart name: `myapp`, version `1.0.0`, app version `1.0.0`
- Type: `application`
- Maintainer: DevOps Team

---

#### `helm/myapp/values.yaml`

| Key | Default | Notes |
|-----|---------|-------|
| `replicaCount` | `2` | Overridden per environment |
| `image.repository` | `nginx` | Replace with your app image |
| `image.tag` | `"1.25"` | Updated by CI pipeline on each build |
| `service.type` | `ClusterIP` | Not exposed externally by default |
| `ingress.enabled` | `false` | Enable and configure per environment |
| `resources.limits.cpu` | `200m` | Adjust based on profiling |
| `autoscaling.enabled` | `false` | Enable for production workloads |

---

#### `helm/myapp/templates/deployment.yaml`
- Uses `{{ include "myapp.fullname" . }}` for consistent, release-scoped naming
- Injects `replicaCount`, `image.repository`, `image.tag`, and `image.pullPolicy` from values
- Applies `resources` (CPU/memory requests and limits) from values
- Conditionally adds environment variables if `env` is set in values

</details>

---

<details>
<summary>📁 <strong>scripts/</strong> — Helper Shell Scripts</summary>

<br>

#### `scripts/install.sh`
Automated setup script. Run once to get a working local environment:

1. Checks for required tools (`kubectl`, `git`) — exits with an error if missing
2. Starts Minikube with `--memory=4096 --cpus=2`
3. Creates the `argocd` namespace idempotently
4. Applies the Argo CD stable install manifest
5. Waits up to 5 minutes for all Argo CD pods to be `Ready`
6. Prints the initial admin password and the port-forward command

---

#### `scripts/cleanup.sh`
Tears down everything:

1. Prompts for `yes` confirmation before proceeding
2. Deletes all Argo CD `Application` resources
3. Deletes the `argocd`, `dev`, `staging`, and `production` namespaces
4. Stops Minikube

</details>

---

<details>
<summary>📁 <strong>docs/</strong> — Architecture and Runbooks</summary>

<br>

#### `docs/architecture.md`
End-to-end system design: the GitOps pipeline from developer commit to Kubernetes rollout, the role of each component, and the full repository layout. Good starting point for new team members.

---

#### `docs/gitops-flow.md`
Documents the pull-based GitOps model:

- The 6-step deployment flow (commit → CI → image push → manifest update → Argo CD sync → rollout)
- Two rollback strategies: `git revert` (preferred) and `argocd app rollback`
- Environment promotion path: `feature branch → PR → main → dev → staging → production`

---

#### `docs/troubleshooting.md`

| Issue | Fix |
|-------|-----|
| Minikube won't start | `minikube delete && minikube start --driver=docker` |
| Argo CD pods stuck pending | `kubectl describe pod` to check events |
| Port 8080 in use | `sudo fuser -k 8080/tcp` then re-run port-forward |
| App shows `OutOfSync` | `argocd app diff myapp` then `argocd app sync myapp --force` |
| DNS / ComparisonError | `argocd app get myapp --refresh` |

</details>

---

<details>
<summary>📁 <strong>apps/ · base/ · overlays/</strong> — Kustomize Multi-Env Setup</summary>

<br>

#### `apps/`
One Argo CD `Application` YAML per environment (`myapp-dev.yaml`, `myapp-staging.yaml`, etc.). Argo CD reads this folder via the root app and reconciles the cluster to match.

#### `base/`
Shared Kubernetes manifests: `Deployment`, `Service`, `ConfigMap`, `ServiceAccount`. Referenced by Kustomize overlays — not applied directly.

#### `overlays/dev/`, `overlays/staging/`, `overlays/production/`
Each contains a `kustomization.yaml` referencing `../../base` and patching environment-specific values: replica count, resource limits, image tag, ingress hostname. Production also has stricter sync options and namespace labels.

</details>

---

## Environments

| Environment | Namespace    | Replicas | Image Tag | Auto-sync       |
|-------------|--------------|----------|-----------|-----------------|
| dev         | `dev`        | 1        | `latest`  | ✅ Enabled       |
| staging     | `staging`    | 2        | per build | ✅ Enabled       |
| production  | `production` | 5        | `v1.0.0`  | ✅ + manual gate |

---

## GitOps Flow

```
1. Developer commits code to main branch
2. GitHub Actions runs tests, builds Docker image, pushes to Docker Hub
3. GitHub Actions updates the image tag in the relevant overlay manifest and commits
4. Argo CD detects the Git change (poll interval: 3 min, or instant via webhook)
5. Argo CD diffs the desired state (Git) vs actual state (cluster)
6. Argo CD applies the diff — Kubernetes rolls out new pods
```

---

## Rollback

```bash
# Option 1 — Revert in Git (recommended, keeps history clean)
git revert HEAD
git push
# Argo CD auto-syncs the revert within 3 minutes

# Option 2 — Argo CD rollback to a specific revision
argocd app rollback myapp <revision-id>
```

---

## Tech Stack

| Tool        | Version    | Purpose                        |
|-------------|------------|--------------------------------|
| Argo CD     | stable     | GitOps continuous delivery     |
| Kubernetes  | 1.28+      | Container orchestration        |
| Minikube    | latest     | Local cluster                  |
| Terraform   | ≥ 1.0      | Infrastructure provisioning    |
| Helm        | v3         | Application packaging          |
| Kustomize   | built-in   | Environment-specific patching  |
| Docker      | latest     | Image build and push           |

---

> **Golden Rule:** Git is the only place you make changes.
> If you `kubectl apply` something directly, Argo CD will revert it.
