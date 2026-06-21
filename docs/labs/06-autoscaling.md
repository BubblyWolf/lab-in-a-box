# Lab 06 — Watch Kubernetes scale your app (the "why K8s" moment) 🟡

## The story

This is the one that explains *why Kubernetes exists.*

You could run a single app with plain Docker — but what happens when a crowd shows up and one copy can't keep up? With Docker, you'd notice, then manually start more copies. With Kubernetes, **the system watches the load and adds copies by itself** — then removes them when the rush is over. You sleep; it scales.

In this lab you'll flood the Pulse app with work and watch the worker grow from **2 pods to 10**, automatically.

## Goal

Trigger the HorizontalPodAutoscaler (HPA) with a burst of load and watch Kubernetes scale the Pulse worker up — then back down.

## Background (30 seconds)

- The Pulse **worker** does real CPU work per job.
- An **HPA** is set to keep worker CPU around 60%, scaling between **2 and 10** pods.
- A load generator floods the app with jobs → worker CPU spikes → HPA adds pods.
- This needs **metrics-server** (installed automatically by `make up`).

## Steps

### 1. Make sure Pulse is running

```bash
make deploy-local
kubectl get hpa -n pulse        # you should see "pulse-worker"
```

### 2. Open a watch window

In one terminal, start watching the worker:

```bash
make watch
```

You'll see 2 worker pods sitting calmly.

### 3. Fire the load (in another terminal)

```bash
make load
```

This launches a job that submits thousands of tasks.

### 4. Watch the magic

Back in the watch window, over the next 1–2 minutes you'll see new worker pods appear:

```
[10s] running worker pods = 2
[50s] running worker pods = 4
[60s] running worker pods = 8
[70s] running worker pods = 10   # maxed out under load
```

Check the autoscaler's reasoning:

```bash
kubectl get hpa pulse-worker -n pulse
# NAME           REFERENCE                 TARGETS         MIN  MAX  REPLICAS
# pulse-worker   Deployment/pulse-worker   cpu: 362%/60%   2    10   10
```

CPU hit **362%** (way over the 60% target), so Kubernetes scaled to the max of 10 pods.

### 5. Watch it scale back down

When the load generator finishes, the queue drains, CPU drops, and after a few minutes Kubernetes **removes** the extra pods — back to 2. No human touched anything.

## ✅ How to check you did it

- The worker pod count rose above 2 (toward 10) during load
- `kubectl get hpa` showed CPU above 60% and REPLICAS climbing
- After the load ended, pods scaled back down on their own

## Why this is the whole point

| | Plain Docker | Kubernetes |
|---|---|---|
| Crowd shows up | You notice, manually `docker run` more | HPA adds pods automatically |
| Crowd leaves | You manually stop them | HPA removes them automatically |
| At 3 AM | You wake up | You sleep |

**This is what companies pay DevOps engineers for** — systems that scale and heal themselves. You just ran it on your laptop.

## Keep experimenting

- Lower the target: `helm upgrade pulse charts/pulse -n pulse --set autoscaling.worker.targetCPUUtilizationPercentage=20` — does it scale sooner?
- Raise the max replicas and run `make load` again.
- Make each job heavier: `--set ...` isn't wired for `WORK_CPU_MS`, but you can edit the worker deployment env and watch CPU climb faster.

<details>
<summary>💡 Solution / expected result</summary>

Running `make load` then `make watch` (or `kubectl get hpa,pods -n pulse -w`) shows the worker Deployment scaling from 2 → 10 replicas as CPU exceeds the 60% target, then back to 2 once the load generator Job completes and the queue empties. Nothing is scaled by hand — the HPA does it all.

Clean up the load job when done:

```bash
kubectl delete job pulse-load -n pulse
```

</details>
