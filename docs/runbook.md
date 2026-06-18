
# Operational Runbook

Common commands, troubleshooting, and day-2 operations for `lab-in-a-box`.

---

## Quick Command Reference

| Command | What it does |
|---------|------------|
| `make up` | Create Kind cluster, install Argo CD, monitoring, security stack |
| `make down` | Destroy Kind cluster and all data |
| `make status` | Show cluster health, pod status, and port-forward status |
| `make demo` | Open Argo CD, Grafana, and Pulse frontend in browser |
| `make deploy-local` | Deploy Pulse app from local path (no Git push needed) |
| `make deploy-gitops` | Deploy Pulse app from Git repo (requires pushed repo) |
| `make test` | Run smoke tests against Pulse API |
| `make lint` | Validate all Kubernetes manifests and Helm charts |

---

## Accessing Services

### Argo CD

```bash
# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port-forward (or use make demo)
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Login via CLI (optional)
argocd login localhost:8080 --username admin --password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
```

URL: https://localhost:8080 (accept the self-signed cert)

### Grafana

```bash
# Get admin password
kubectl -n monitoring get secret grafana-admin -o jsonpath="{.data.password}" | base64 -d

# Default credentials: admin / (password above)
```

URL: http://localhost:3000

### Pulse Frontend

```bash
kubectl port-forward svc/pulse-frontend -n pulse 8081:80
```

URL: http://localhost:8081

---

## Testing Security Policies

### Verify Kyverno is blocking bad pods

```bash
# Should fail with policy violations
kubectl apply -f security/examples/bad-pod.yaml

# Expected output includes:
# - require-resources: CPU and memory limits required
# - disallow-root: Running as root not allowed
# - require-ro-rootfs: Read-only root filesystem required

# Verify good pods pass
kubectl apply -f security/examples/good-pod.yaml
kubectl delete -f security/examples/good-pod.yaml
```

### Check policy status

```bash
# List all policies and their status
kubectl get clusterpolicies

# See recent policy reports
kubectl get policyreports -A
```

### Test sealed secrets workflow

```bash
# Create a secret and seal it
kubectl create secret generic my-secret --from-literal=password=hunter2 --dry-run=client -o yaml | \
  kubeseal --controller-namespace=sealed-secrets --controller-name=sealed-secrets -o yaml > my-sealed-secret.yaml

# Apply the sealed secret (safe for Git)
kubectl apply -f my-sealed-secret.yaml

# Verify it was decrypted
kubectl get secret my-secret -o jsonpath="{.data.password}" | base64 -d
```

---

## Troubleshooting

### Pods stuck in Pending

```bash
# Check why
kubectl describe pod <pod-name> -n <namespace>

# Common causes
kubectl get nodes                    # Are nodes Ready?
kubectl top nodes                  # Resource exhaustion?
kubectl get events --sort-by='.lastTimestamp' -n <namespace>

# Fix: If Kind cluster is overloaded, increase Docker resources
# or: make down && make up
```

### ImagePullBackOff / ErrImagePull

```bash
# Check image name and tag
kubectl get pod <pod-name> -o yaml | grep image:

# For locally built images not in registry
# Images must be loaded into Kind:
kind load docker-image <image>:<<tag> --name lab-in-a-box

# Or use GHCR images (CI-built)
# Update image tag in charts/pulse/values.yaml
```

### Argo CD app shows OutOfSync

```bash
# View diff
argocd app diff pulse-app

# Common causes:
# 1. Manual cluster changes -> Argo will self-heal on next sync
# 2. Kustomize/Helm rendering differences -> Check repo-server logs
# 3. Resource not in Git -> Add to appropriate app directory

# Force sync
argocd app sync pulse-app

# Or via kubectl
kubectl patch application pulse-app -n argocd --type merge -p '{"operation": {"sync": {"syncStrategy": {"hook": {"force": true}}}}}'
```

### Argo CD app shows Degraded

```bash
# Check app health
argocd app get pulse-app

# Check resource events
kubectl get events -n pulse --field-selector reason=Failed

# Common: dependent service not ready (e.g., Redis before API)
# Argo CD has custom health checks; check resource status individually
kubectl get pods,services -n pulse
```

### Grafana dashboard missing

```bash
# Check ConfigMap is loaded
kubectl get configmap -n monitoring | grep grafana-dashboard

# Check Grafana pod logs
kubectl logs -n monitoring -l app.kubernetes.io/name=grafana

# Force dashboard reload
kubectl rollout restart deployment/grafana -n monitoring
```

### Port forwards dying

Port-forwards are not persistent. Use `make demo` to re-establish, or run in background:

```bash
# Persistent port-forward with auto-reconnect
# Install: https://github.com/jonmosco/kube-ps1 or use screen/tmux

# Alternative: kubectl proxy for API access
kubectl proxy --port=8001
```

### Reset everything (nuclear option)

```bash
make down && make up && make deploy-local
```

Takes ~3-5 minutes depending on machine and network.

---

## Performance & Scaling

### Kind cluster specs

Default `bootstrap/kind-config.yaml`:
- 1 control-plane node (no workload scheduling)
- 2 worker nodes
- Port mappings: 8080, 3000, 8081, 9090

### Adjust for your machine

```yaml
# bootstrap/kind-config.yaml
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            system-reserved: memory=1Gi  # Increase if OOM
  - role: worker
    extraMounts:
      - hostPath: /tmp
        containerPath: /data  # For persistent testing
```

### Resource limits on Pulse app

Default in `charts/pulse/values.yaml`:
- API: 100m CPU, 128Mi memory
- Worker: 100m CPU, 128Mi memory
- Frontend: 50m CPU, 64Mi memory

Increase for load testing; decrease if cluster is starved.

---

## Backup & Restore

### Save cluster state

```bash
# Export all manifests
kubectl get all -A -o yaml > cluster-backup.yaml

# Or use velero (overkill for local, but good practice)
```

### Sealed secrets backup

The Sealed Secrets controller's private key is critical. Back up:

```bash
kubectl get secret -n sealed-secrets -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml > sealed-secrets-master-key.yaml
```

Restore on new cluster before applying sealed secrets.

---

## CI/CD Pipeline Debugging

### Run CI locally with act

```bash
# Install: https://github.com/nektos/act
act push -j build  # Run build job locally
```

### Check workflow status

```bash
# GitHub CLI
gh run list
gh run view <run-id>
gh run watch
```

### Common CI failures

| Symptom | Cause | Fix |
|---------|-------|-----|
| `cosign sign` fails | Missing `COSIGN_PRIVATE_KEY` secret | Add to repo Settings > Secrets |
| Trivy scan slow | Large image or DB download | Use `TRIVY_OFFLINE_SCAN=true` or cache |
| `helm lint` fails | Chart version mismatch | Update `Chart.yaml` version |
