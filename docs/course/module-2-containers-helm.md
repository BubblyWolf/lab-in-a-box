# Module 2 — Containers, images & Helm

**Tool focus**: Docker, Helm  
**Estimated time**: 45 minutes

---

## Learning objectives

- Explain what a container image is and how a Dockerfile builds one
- Read a Helm chart and understand how values inject into templates
- Modify a chart value and observe the change in the running application

---

## The story to tell

Open `docs/concepts.md` and walk through the **identical lunchbox + the recipe book** analogy.

> Every customer gets the same lunchbox — same sandwich, same apple, same juice. The lunchbox is the *image*. The recipe that says "use wholegrain bread, add one apple" is the *Dockerfile*. Now, some customers want gluten-free. You don't rebuild the whole kitchen; you have a *template* (the chart) and a *preferences card* (values.yaml). Helm combines the template with the preferences to generate the exact lunchbox for each customer.

Key terms:
- **Image**: the sealed lunchbox
- **Dockerfile**: the recipe to build it
- **Chart**: the reusable template with placeholders
- **values.yaml**: the preferences card that fills the placeholders
- **Helm template**: the "dry run" that shows what Kubernetes YAML would be generated

---

## Live demo script

**Step 1: Inspect a Dockerfile**

```bash
cat apps/demo/Dockerfile
```

Talk through:
- `FROM` — the base image (starting ingredients)
- `COPY` — adding your application code
- `RUN` — installing dependencies
- `CMD` — what runs when the container starts

**Step 2: Inspect the Helm chart**

```bash
ls charts/pulse/
cat charts/pulse/Chart.yaml
cat charts/pulse/values.yaml
```

Show:
- `Chart.yaml` — metadata (name, version, dependencies)
- `values.yaml` — defaults (replica count, image tag, service type)
- `templates/` — the Kubernetes YAML with `{{ .Values }}` placeholders

**Step 3: Render templates without deploying**

```bash
helm template charts/pulse
```

This is the "dry run." Show how `replicas: {{ .Values.replicaCount }}` becomes `replicas: 2` (or whatever value is set).

Try with a custom value:

```bash
helm template charts/pulse --set replicaCount=5
```

Point out: only the number changed. The template stayed the same.

**Step 4: Show the deployed chart in Argo CD**

```bash
make demo
```

In Argo CD, click the Pulse app → "Parameters" tab. Show how values from `values.yaml` appear there. This is the bridge from Module 1: Argo CD deploys the Helm chart, which is the "recipe book" for the lunchbox.

---

## Classroom exercise

Direct students to inspect and modify:

```bash
# See current values
cat charts/pulse/values.yaml

# Change something visible
# Edit charts/pulse/values.yaml to set replicaCount: 3
# Save, then:
helm template charts/pulse | grep -A 5 replicas

# Or apply and watch Argo CD sync:
make deploy-local
```

Challenge: Change the service port or add a label. Watch Argo CD detect the diff and sync.

---

## Discussion questions

1. Why not just write Kubernetes YAML directly? When does Helm's complexity pay off?
2. What risks come from using a `FROM` image you didn't build?
3. If you change `values.yaml` but forget to commit to Git, what does Argo CD do?

---

## Common student questions & answers

**Q: Is Helm like apt/yum for Kubernetes?**  
A: Close enough for beginners. It packages, versions, and configures applications. The "repository" concept is similar.

**Q: Why do I see `{{ .Values }}` everywhere?**  
A: Go templates. Helm uses the Go language's templating engine. `{{ }}` is the syntax for "insert value here."

**Q: Can I template a Dockerfile?**  
A: BuildKit has some features, but typically no — the Dockerfile is static. The *build arguments* (`ARG`) provide limited flexibility. Helm charts are where the real templating happens for deployment.

**Q: What's the difference between `helm template` and `helm install`?**  
A: `template` renders YAML to stdout (safe, no changes). `install` or `upgrade` sends it to the cluster. Argo CD effectively does `template` + `kubectl apply` for you.

---

## Time breakdown

| Segment | Time |
|---------|------|
| Story & concepts | 10 min |
| Live demo | 15 min |
| Student exercise | 15 min |
| Discussion & wrap | 5 min |