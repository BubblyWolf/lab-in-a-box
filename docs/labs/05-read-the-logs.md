# Lab 05 — Become a detective with logs

## The story

Something is happening inside your cluster. Jobs are processing, requests are flying, but it's all invisible. Time to shine a light. Grab a pod's logs, watch it react to your actions, and learn to read the story your apps are telling.

## Goal

Read logs from a `pulse-worker` pod, correlate frontend actions with log output, and optionally explore the Grafana dashboard.

## Steps

### 1. Find a worker pod

```bash
kubectl get pods -n pulse
```

Pick any `pulse-worker` pod name.

### 2. Read its current logs

```bash
kubectl logs pulse-worker-3a2b1c0d9-e7f8g -n pulse
```

You may see startup messages, heartbeat checks, or "waiting for job" lines. Note the last few lines.

### 3. Open the Pulse frontend and create activity

```bash
make demo
```

Find the Pulse frontend URL and open it. Submit a test job or refresh the page to generate API calls. (The exact UI depends on the Pulse version — look for buttons like "Submit Job" or "Trigger Worker".)

### 4. Watch logs react in real time

In another terminal, stream the logs:

```bash
kubectl logs -f pulse-worker-3a2b1c0d9-e7f8g -n pulse
```

Now go back to the frontend and trigger more actions. Watch new lines appear in your terminal.

### 5. Check all workers at once

```bash
kubectl logs -n pulse -l app=pulse-worker --tail=20
```

This shows the last 20 lines from all worker pods combined.

### 6. (Optional) Open Grafana and find the dashboard

```bash
make demo
```

Find the Grafana URL and log in. Navigate to **Dashboards** → **Browse** and look for a Pulse or container logs dashboard. This gives you a visual, aggregated view of what you just saw in the terminal.

## ✅ How to check you did it

- You can quote a specific log line that appeared after your frontend action
- You can explain the difference between `kubectl logs` (one pod) and `kubectl logs -l` (selector, multiple pods)
- (Optional) You found a Grafana dashboard showing pod or application metrics

## Reading logs like a pro

| Command | What it does |
|---------|--------------|
| `kubectl logs pod-name` | Snapshot of current logs |
| `kubectl logs -f pod-name` | Live stream, like `tail -f` |
| `kubectl logs --previous pod-name` | Logs from crashed container's last run |
| `kubectl logs -l app=name` | Logs from all pods matching label |
| `kubectl logs pod-name -c container-name` | Specific container in multi-container pod |

## Keep experimenting

- Crash a pod on purpose: `kubectl delete pod pulse-worker-... -n pulse`, then immediately `kubectl logs -f` the replacement — see startup sequence
- Add `--timestamps` to see exact timing: `kubectl logs -n pulse -l app=pulse-worker --timestamps`
- Find error lines: `kubectl logs -n pulse -l app=pulse-api | grep -i error`
- Check Argo CD logs for deployment events: `kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server`

<details>
<summary>💡 Solution</summary>

**Find and read logs:**

```bash
# Get pod name
kubectl get pods -n pulse | grep pulse-worker

# Read once
kubectl logs pulse-worker-<your-pod> -n pulse

# Stream live (run this, then use the frontend)
kubectl logs -f pulse-worker-<your-pod> -n pulse
```

**Correlate action to log:**

Example pattern you might see after frontend activity:

```
[2024-01-15T10:23:45Z] INFO: Received job: process-data
[2024-01-15T10:23:45Z] INFO: Processing item ID: 42
[2024-01-15T10:23:46Z] INFO: Job completed: success
```

**Multi-pod logs:**

```bash
kubectl logs -n pulse -l app=pulse-worker --tail=20
```

**Grafana path:**

1. `make demo` → note Grafana URL
2. Log in (default credentials may be `admin` / check cluster setup)
3. **Dashboards** → **Browse** → look for:
   - "Kubernetes / Pods" or similar for container metrics
   - "Pulse" or application-specific dashboard if installed
4. Try the "Logs" panel — it may use Loki to aggregate from all pods

**Troubleshooting:**

| Problem | Fix |
|---------|-----|
| `Error from server: Get ... dial tcp ... connect: connection refused` | Pod may be restarting; try `--previous` or wait and retry |
| No new logs appear | Verify you're hitting the right pod; check `kubectl get pods -n pulse -l app=pulse-worker` |
| Grafana shows no data | Ensure monitoring stack is fully ready: `kubectl get pods -n monitoring` |

</details>