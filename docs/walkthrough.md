# 🎓 Guided Walkthrough — Learn by Running

This is the heart of `lab-in-a-box`: don't just deploy it, **understand it**. Follow along and watch each layer of a real production platform work on your own machine. Every output below is from an actual run — you should see the same.

> ⏱️ ~5 minutes of hands-on time (plus image pulls on first run).
> 📦 Prereqs: Docker running, plus `kind`, `kubectl`, `helm`. See the [README](../README.md#-quickstart).

---

## Step 0 — What you're about to build

```
your laptop
└── Kind cluster (3 nodes, all in Docker)
    ├── Pulse app      → API + worker + frontend + Redis  (the workload)
    ├── Argo CD        → GitOps: deploys apps from Git
    ├── Prometheus/Grafana/Loki → metrics + logs
    └── Kyverno        → security policies that block bad pods
```

Nothing leaves your machine. Delete it anytime with `make down`.

---

## Step 1 — Spin up the cluster

```bash
make up
```

This creates a 3-node Kubernetes cluster inside Docker. You'll see:

```
 ✓ Preparing nodes 📦 📦 📦
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Joining worker nodes 🚜
Set kubectl context to "kind-lab-in-a-box"
```

**What just happened:** `kind` booted a full Kubernetes control plane + 2 workers as Docker containers. Verify:

```bash
kubectl get nodes
# NAME                         STATUS   ROLES           VERSION
# lab-in-a-box-control-plane   Ready    control-plane   v1.31.0
# lab-in-a-box-worker          Ready    <none>          v1.31.0
# lab-in-a-box-worker2         Ready    <none>          v1.31.0
```

> 💡 **Learn:** A real cluster has a control plane (the brain) and worker nodes (where your apps run). Kind gives you all of it locally.

---

## Step 2 — Deploy the demo app

```bash
make deploy-local
```

This builds the 3 Pulse images, loads them into the cluster, and installs the Helm chart. After ~30s:

```bash
kubectl get pods -n pulse
# pulse-api-xxxx        1/1   Running
# pulse-frontend-xxxx   1/1   Running
# pulse-redis-xxxx      1/1   Running
# pulse-worker-xxxx     1/1   Running
# pulse-worker-yyyy     1/1   Running   ← 2 worker replicas
```

> 💡 **Learn:** The `api` may briefly show `0/1` — it waits for Redis to accept connections before reporting healthy. That's a **readiness probe** doing its job, and it self-heals. This is how production apps avoid serving traffic before they're ready.

---

## Step 3 — Watch the app actually work

Port-forward the API and submit some jobs:

```bash
kubectl port-forward -n pulse svc/pulse-api 3001:3001 &

curl http://localhost:3001/stats
# {"submitted":0,"processed":0,"pending":0}

# submit 5 jobs
for i in 1 2 3 4 5; do
  curl -s -X POST http://localhost:3001/jobs -H 'content-type: application/json' -d '{"type":"demo"}'
done

curl http://localhost:3001/stats
# {"submitted":5,"processed":5,"pending":0}   ← workers picked them up!
```

**What just happened:** The API pushed jobs onto a Redis queue. The worker pods `BLPOP`'d them off, processed them, and incremented the counter. This is the classic **producer → queue → consumer** pattern that powers real job systems.

Check the Prometheus metrics the app exposes:

```bash
curl http://localhost:3001/metrics | grep pulse_
# pulse_jobs_submitted_total 5
```

> 💡 **Learn:** Every service exposes `/metrics`. That's what Prometheus scrapes to build dashboards — no extra agents needed.

---

## Step 4 — See the security policies block a bad pod

This is the fun one. Try to deploy a deliberately insecure pod:

```bash
kubectl apply -f security/examples/bad-pod.yaml
```

You get **rejected at admission time**:

```
Error from server: admission webhook "validate.kyverno.svc-fail" denied the request:

disallow-privileged:
  Privileged containers are not allowed.
require-non-root:
  Pod must run as non-root.
```

**What just happened:** Kyverno is an **admission controller** — it inspects every pod *before* it's created and rejects ones that violate policy. The bad pod runs privileged and as root, so two enforced policies block it. Meanwhile the Pulse app pods pass cleanly (they run non-root, unprivileged).

> 💡 **Learn:** This is "shift-left security" — you stop insecure workloads at the door instead of finding them later. See [`security/policies/`](../security/policies/) for all four policies (2 enforced, 2 audit-only).

---

## Step 5 — Explore the dashboards

```bash
make demo
```

Opens port-forwards for:

| URL | What to look at |
|-----|-----------------|
| https://localhost:8080 | **Argo CD** — see apps synced from Git |
| http://localhost:3000 | **Grafana** → "Pulse" dashboard → submit more jobs and watch the **Job Rate** graph move |
| http://localhost:8081 | **Pulse frontend** — click "Submit Job", watch the live counters |

> 💡 **Learn:** Submit jobs in the frontend while watching Grafana. You're seeing the full loop: app → metrics → Prometheus → Grafana, live.

---

## Step 6 — Clean up

```bash
make down
```

Deletes the entire cluster. Your laptop is exactly as it was. Run `make up` anytime to start fresh.

---

## Where to go next

- 📐 **[Architecture](architecture.md)** — how the pieces connect and why
- 🛠️ **[Runbook](runbook.md)** — common commands and troubleshooting
- 🔧 **Tinker** — change a policy, add a metric, break something on purpose. That's what this lab is for.

Found this useful? ⭐ the repo and tell me what you learned.
