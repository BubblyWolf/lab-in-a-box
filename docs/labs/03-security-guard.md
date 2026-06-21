# Lab 03 — Meet the security guard

## The story

A new developer on your team just tried to deploy a pod running as root with privileged access. Disaster? Not here — your cluster has a security guard named Kyverno. Your job is to test the guard, get blocked, and learn how to write code that passes inspection.

## Goal

Prove that Kyverno blocks insecure pods. Read the denial message. Then write and deploy a compliant pod that satisfies the security policies.

## Steps

### 1. Try to deploy the intentionally bad pod

```bash
kubectl apply -f security/examples/bad-pod.yaml
```

This pod runs as root and requests privileged mode. Watch what happens.

### 2. Read the denial message

Kyverno should reject it with a message citing `require-non-root` and `disallow-privileged`. The exact wording depends on which policy triggers first. Read carefully — this is how security tools communicate.

Example output to look for:

```
Error from server: error when creating "security/examples/bad-pod.yaml":
admission webhook "validate.kyverno.svc-fail" denied the request:
resource Pod/default/bad-pod was blocked:
policy require-non-root ...
```

### 3. Write a compliant pod

Create a file named `good-pod.yaml`. We use `busybox` with an explicit non-root user so it actually starts. (Real-world gotcha: many images — like the default `nginx` — insist on running as root, so even after Kyverno admits them the kubelet refuses to start them. Choosing a non-root-capable image is part of doing security right.)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: good-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
  containers:
    - name: app
      image: busybox:1.36
      command: ["sh", "-c", "echo I am compliant && sleep 3600"]
      securityContext:
        allowPrivilegeEscalation: false
        privileged: false
      resources:
        requests:
          memory: "32Mi"
          cpu: "50m"
        limits:
          memory: "64Mi"
          cpu: "100m"
```

### 4. Deploy your good pod

```bash
kubectl apply -f good-pod.yaml
```

### 5. Verify it runs

```bash
kubectl get pods
```

## ✅ How to check you did it

- `bad-pod` is **rejected** with a clear Kyverno denial message
- `good-pod` is **accepted** and reaches `Running` status
- You can explain why each security field was needed

## The policies in your cluster

| Policy | Mode | What it enforces |
|--------|------|----------------|
| `require-non-root` | Enforce | Containers must run as non-root user |
| `disallow-privileged` | Enforce | Containers cannot run in privileged mode |
| `require-resources` | Audit | Containers should have resource requests/limits |
| `disallow-latest-tag` | Audit | Images should not use `:latest` tag |

## Keep experimenting

- Remove `runAsNonRoot: true` from your good pod — does it still pass? (Hint: `require-non-root` is Enforce mode)
- Remove `resources:` — does it still pass? (Hint: `require-resources` is Audit mode, so it warns but doesn't block)
- Check Kyverno policy reports: `kubectl get policyreport -A`
- Try `kubectl get clusterpolicies` to see all active rules

<details>
<summary>💡 Solution</summary>

**The bad pod rejection:**

```bash
kubectl apply -f security/examples/bad-pod.yaml
```

Expected output (truncated):

```
Error from server: error when creating "security/examples/bad-pod.yaml":
admission webhook "validate.kyverno.svc-fail" denied the request:
resource Pod/default/bad-pod was blocked:
policy require-non-root failed:
rule run-as-non-root ...
```

**The good pod (`good-pod.yaml`):**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: good-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
  containers:
    - name: app
      image: busybox:1.36
      command: ["sh", "-c", "echo I am compliant && sleep 3600"]
      securityContext:
        allowPrivilegeEscalation: false
        privileged: false
      resources:
        requests:
          memory: "32Mi"
          cpu: "50m"
        limits:
          memory: "64Mi"
          cpu: "100m"
```

Deploy and verify:

```bash
kubectl apply -f good-pod.yaml
kubectl get pod good-pod
kubectl describe pod good-pod
```

Clean up when done:

```bash
kubectl delete pod good-pod
```

**Why each field matters:**

| Field | Satisfies |
|-------|-----------|
| `runAsNonRoot: true` + `runAsUser: 1000` | `require-non-root` (and lets the pod actually start as non-root) |
| `privileged: false` | `disallow-privileged` |
| `resources.requests/limits` | `require-resources` (Audit — logs warning if missing) |
| `busybox:1.36` (not `:latest`) | `disallow-latest-tag` (Audit — logs warning) |

</details>