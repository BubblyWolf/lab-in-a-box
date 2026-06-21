# Lab 02 — Watch Kubernetes heal itself

## The story

Your microservices are running peacefully. Then disaster strikes: a pod disappears. Will the system panic? Nope — Kubernetes was built for chaos. Your job is to cause that chaos and watch the recovery.

## Goal

Demonstrate Kubernetes self-healing by deleting a pod and observing its replacement. Then scale a deployment up and down.

## Steps

### 1. Check the current state

```bash
kubectl get pods -n pulse
```

Note the names. You'll need one `pulse-api` pod name for the next step.

### 2. Delete a pod and watch the magic

Pick any `pulse-api` pod and delete it:

```bash
kubectl delete pod pulse-api-7d9f4b8c5-x2k1m -n pulse
```

Immediately watch what happens:

```bash
kubectl get pods -n pulse -w
```

You'll see the deleted pod terminate, and a new `pulse-api` pod appear with a fresh name and age. Press `Ctrl+C` to stop watching.

### 3. Scale the worker deployment

Pulse workers process background jobs. Let's give it more horsepower:

```bash
kubectl scale deploy/pulse-worker -n pulse --replicas=4
```

Check the result:

```bash
kubectl get pods -n pulse
```

You should now see four `pulse-worker` pods.

### 4. Scale back down

```bash
kubectl scale deploy/pulse-worker -n pulse --replicas=1
```

## ✅ How to check you did it

- After deleting a `pulse-api` pod, a replacement appears within seconds
- `pulse-worker` pod count changes from 1 to 4, then back to 1
- The Pulse frontend still works throughout (open it to verify)

## Why this works

A **Deployment** declares the desired state: "I want 1 API pod and 1 worker pod." The **controller** constantly compares reality to that desire. When you delete a pod, reality falls behind; the controller creates a replacement. When you scale, you change the desire; the controller adjusts accordingly.

## Keep experimenting

- Delete multiple pods at once: `kubectl delete pods -l app=pulse-api -n pulse`
- Try `kubectl get events -n pulse` to see the controller's actions in real time
- Scale `pulse-frontend` to 2 replicas — does it work? What happens to the service?

<details>
<summary>💡 Solution</summary>

**Delete and watch:**

```bash
# Get current pods
kubectl get pods -n pulse

# Delete one (use your actual pod name)
kubectl delete pod pulse-api-<your-pod-name> -n pulse

# Watch in another terminal, or run immediately after
kubectl get pods -n pulse -w
```

**Scale up and down:**

```bash
kubectl scale deploy/pulse-worker -n pulse --replicas=4
kubectl get pods -n pulse | grep pulse-worker  # should show 4
kubectl scale deploy/pulse-worker -n pulse --replicas=1
kubectl get pods -n pulse | grep pulse-worker  # should show 1
```

**Expected output pattern:**

```
NAME                              READY   STATUS
pulse-worker-3a2b1c0d9-e7f8g     1/1     Running
pulse-worker-9f8e7d6c5-b4a3c     1/1     Running
pulse-worker-1a2b3c4d5-e6f7g     1/1     Running
pulse-worker-5d6e7f8g9-h0i1j     1/1     Running
```

If scaling doesn't work, check the deployment status:

```bash
kubectl describe deploy/pulse-worker -n pulse
```

</details>