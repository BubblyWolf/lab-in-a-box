# Module 4 — Security & guardrails

**Tool focus**: Kyverno, Trivy, Sealed Secrets  
**Estimated time**: 45 minutes

---

## Learning objectives

- Explain why "shift left" security catches problems before production
- Demonstrate a Kyverno policy blocking an insecure pod
- Describe the purpose of image scanning and secret encryption

---

## The story to tell

Open `docs/concepts.md` and walk through the **security guard + health inspector** analogy.

> Every morning, a security guard checks IDs at the kitchen door. No ID, no entry — that's Kyverno, enforcing policies on what can run. Meanwhile, the health inspector examines ingredients: is the meat expired? Are pesticides on the vegetables? That's Trivy, scanning images for vulnerabilities. And the manager's safe? It holds the secret recipes, but only the manager has the key. Sealed Secrets encrypts sensitive data so even if someone steals the recipe book, they can't read the secret ingredient.

Key terms:
- **Policy**: a rule about what is allowed (Kyverno)
- **Vulnerability scan**: checking for known weaknesses (Trivy)
- **Secret encryption**: protecting sensitive configuration (Sealed Secrets)
- **Shift left**: catching problems earlier in the pipeline

---

## Live demo script

**Step 1: Confirm Kyverno is running**

```bash
kubectl get pods -n kyverno
```

**Step 2: Show the policy**

```bash
kubectl get clusterpolicy
kubectl describe clusterpolicy require-non-root
# or your policy name
```

Read the policy in plain language: "Pods must not run as root."

**Step 3: Attempt to deploy something bad**

```bash
cat security/examples/bad-pod.yaml
```

Show it: `runAsUser: 0` (root), no security context.

```bash
kubectl apply -f security/examples/bad-pod.yaml
```

Watch it fail. Show the error message from Kyverno.

```bash
Error from server: error when creating "security/examples/bad-pod.yaml": admission webhook "validate.kyverno.svc-fail" denied the request: ...
```

**Step 4: Fix and retry**

Have students write a compliant `good-pod.yaml` (this is exactly Lab 3, [`docs/labs/03-security-guard.md`](../labs/03-security-guard.md)) — a non-root, non-privileged pod with resource requests — and apply it:

```bash
kubectl apply -f good-pod.yaml
kubectl get pod good-pod    # reaches Running
```

Success. The guard let them through.

**Step 5: Mention Trivy (the health inspector)**

Trivy scans container images for known vulnerabilities. In this lab it runs two places:
- In CI on every push (see [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml) — the "Install Trivy" + "Trivy scan" steps).
- In-cluster via the Trivy Operator (deployed by `gitops/apps/trivy.yaml`). Show the reports:

```bash
kubectl get vulnerabilityreports -A
```

Point out HIGH / CRITICAL findings — this is the health inspector flagging spoiled ingredients.

**Step 6: Mention Sealed Secrets**

Explain the idea: a normal Kubernetes Secret is only base64-encoded (not encrypted), so you must never commit it to Git. Sealed Secrets (deployed via `gitops/apps/sealed-secrets.yaml`) lets you **encrypt** a secret so it's safe to commit — only the cluster can decrypt it. Teaching point: GitOps needs a safe way to store secrets in Git, and this is it.

---

## Classroom exercise

Direct students to `docs/labs/03-security-guard`:

- Try to apply `bad-pod.yaml`, document the Kyverno error
- Modify to pass the policy, apply successfully
- (Optional) Run Trivy on a public image and discuss findings

---

## Discussion questions

1. Who writes security policies — developers, ops, or a dedicated team?
2. What happens if a critical vulnerability has no fix yet? (accept risk, isolate, or stop deployment?)
3. Why encrypt secrets if the repository is private?
4. How does "shift left" change when developers own the CI pipeline?

---

## Common student questions & answers

**Q: Can't I just disable Kyverno if it's blocking me?**  
A: Only if you have cluster-admin rights. In production, developers don't. The guard exists because someone *will* try to sneak in.

**Q: Trivy found 500 vulnerabilities. Do I fix them all?**  
A: Prioritize by severity, exploitability, and whether the vulnerable library is actually used. Focus on CRITICAL and HIGH in running code.

**Q: What's the difference between Sealed Secrets and external secret managers?**  
A: Sealed Secrets is "GitOps-native" — encrypted data lives in Git. External managers (Vault, AWS Secrets Manager) keep secrets outside. Both valid; Sealed Secrets is simpler for this course.

**Q: Does Kyverno replace RBAC?**  
A: No — they complement. RBAC says "who can do what." Kyverno says "what is allowed to exist." Both are needed.

---

## Time breakdown

| Segment | Time |
|---------|------|
| Story & concepts | 10 min |
| Live demo | 15 min |
| Student exercise | 15 min |
| Discussion & wrap | 5 min |