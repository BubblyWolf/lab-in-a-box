# Security Layer for lab-in-a-box

This directory contains Kyverno policies, Sealed Secrets configuration, and security examples for the lab-in-a-box platform.

## Components

| Component | Purpose | Deployed Via |
|-----------|---------|------------|
| Kyverno | Kubernetes policy engine | Argo CD (Helm) |
| Sealed Secrets | Encrypt secrets for GitOps | Argo CD (Helm) |
| Trivy Operator | In-cluster vulnerability scanning | Argo CD (Helm) |

## Kyverno Policies

| Policy | Action | Purpose |
|--------|--------|---------|
| `require-non-root` | **Enforce** | Blocks pods running as root |
| `disallow-privileged` | **Enforce** | Blocks privileged containers |
| `require-resources` | **Audit** | Warns on missing CPU/memory requests |
| `disallow-latest-tag` | **Audit** | Warns on `:latest` or untagged images |

> **Note:** `require-resources` and `disallow-latest-tag` are **Audit** (not Enforce) to avoid breaking the platform or the Pulse app, which uses `:latest` tags.

## Namespace Exclusions

All policies exclude these system/platform namespaces to prevent self-denial-of-service:
`kube-system`, `kube-node-lease`, `kube-public`, `kyverno`, `argocd`, `monitoring`, `logging`, `sealed-secrets`, `trivy-system`, `local-path-storage`

## Testing Policies

Apply the intentionally insecure pod to verify enforcement:

```bash
kubectl apply -f security/examples/bad-pod.yaml
```

**Expected result:** BLOCKED by `require-non-root` and `disallow-privileged` policies.

## Trivy Operator

Trivy automatically scans running workloads. View vulnerability reports:

```bash
kubectl get vulnerabilityreports -A
```

Or for a specific workload:

```bash
kubectl get vulnerabilityreports -n <namespace>
```

## Sealed Secrets

Use `kubeseal` to encrypt secrets for GitOps:

```bash
kubeseal --controller-namespace=sealed-secrets --format yaml < my-secret.yaml > my-sealed-secret.yaml
