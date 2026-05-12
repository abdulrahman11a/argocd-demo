# GitOps Flow

## The Golden Rule

> **Git is the single source of truth.**
> Never modify the cluster directly.

## Pull vs Push Model

| Model | Who applies changes | Example |
|-------|-------------------|---------|
| Push (traditional) | CI/CD pipeline | Jenkins, GitLab CI |
| Pull (GitOps) | Agent inside cluster | Argo CD, Flux |

## Our Flow

1. **Developer** makes a change → commits to `main`
2. **GitHub Actions** builds & tests → pushes Docker image
3. **GitHub Actions** updates `deployment.yaml` with new image tag
4. **Argo CD** detects the change in Git (polling every 3 min or webhook)
5. **Argo CD** applies the diff to the cluster
6. **Kubernetes** rolls out the new pods

## Rollback

```bash
# Option 1: Revert the Git commit
git revert HEAD
git push
# Argo CD auto-syncs the revert

# Option 2: Argo CD rollback
argocd app rollback myapp <revision-id>
```

## Environment Promotion
feature branch → PR → main → auto deploy to dev
↓ manual approval
staging
↓ manual approval
production
