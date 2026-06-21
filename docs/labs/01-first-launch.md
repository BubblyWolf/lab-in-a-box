# Lab 01 — Spin it up and look around

## The story

You've been handed the keys to a miniature data center that lives on your laptop. Your first mission: wake it up, deploy an application, and prove you can see it breathing.

## Goal

Start the lab-in-a-box platform, deploy the Pulse demo application, open its dashboards, and list the running pods in the `pulse` namespace.

## Steps

### 1. Start the platform

```bash
make up
```

This creates a local Kind cluster and installs Argo CD, monitoring, and security tooling. Grab coffee — it takes 2–3 minutes.

Check that everything is healthy:

```bash
make status
```

### 2. Deploy the Pulse application

```bash
make deploy-local
```

This installs the Pulse chart into the `pulse` namespace. Pulse is a small microservices app with three services: an API, a worker, and a frontend, plus Redis for caching.

### 3. Open the dashboards

```bash
make demo
```

This command prints URLs and opens browser tabs for Argo CD, Grafana, and other UIs. Keep these handy — we'll use them in later labs.

### 4. Find the running pods

```bash
kubectl get pods -n pulse
```

You should see something like:

```
NAME                              READY   STATUS    RESTARTS   AGE
pulse-api-7d9f4b8c5-x2k1m         1/1     Running   0          2m
pulse-frontend-5c4d7e8f9-a3b2c     1/1     Running   0          2m
pulse-redis-6b8c9d0e1-f4g5h       1/1     Running   0          2m
pulse-worker-3a2b1c0d9-e7f8g     1/1     Running   0          2m
```

## ✅ How to check you did it

- `make status` shows healthy components
- `kubectl get pods -n pulse` shows four pods, all `Running`
- You can open the Pulse frontend in your browser (find the URL from `make demo` output, or check Argo CD for the service endpoint)

## What just happened?

You now have a live Kubernetes cluster running real microservices. The `pulse` namespace is isolated from other apps. Argo CD is watching the cluster. Grafana is collecting metrics. This is your sandbox.

## Keep experimenting

- Run `kubectl get pods -n pulse -w` to watch pods in real time
- Try `kubectl describe pod <pod-name> -n pulse` to see details
- Run `kubectl get namespaces` to see what else is installed

<details>
<summary>💡 Solution</summary>

If pods are stuck in `Pending`, check cluster resources:

```bash
kubectl get nodes
kubectl describe pod <pod-name> -n pulse
```

The Pulse frontend service is typically exposed via port-forward or NodePort. Find it with:

```bash
kubectl get svc -n pulse
```

Look for `pulse-frontend` and its port mapping.

</details>