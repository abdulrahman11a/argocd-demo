server:
  extraArgs:
    - --insecure
  service:
    type: ClusterIP

configs:
  params:
    server.insecure: true
  cm:
    url: https://argocd.example.com

repoServer:
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 100m
      memory: 256Mi

redis:
  resources:
    limits:
      cpu: 200m
      memory: 256Mi
