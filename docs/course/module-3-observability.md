# Module 3 — Seeing inside the system

**Tool focus**: Prometheus, Grafana, Loki  
**Estimated time**: 45 minutes

---

## Learning objectives

- Distinguish metrics (numbers over time) from logs (event records)
- Use Grafana to visualize Pulse application load
- Query and filter logs with `kubectl logs` and Loki

---

## The story to tell

Open `docs/concepts.md` and walk through the **CCTV cameras + wall of screens + the diary** analogy.

> The restaurant has CCTV cameras watching every station: grill temperature, fridge door open/close, customers per hour. These numbers stream to a wall of screens — that's Prometheus scraping metrics and Grafana displaying dashboards. Meanwhile, each cook keeps a diary: "10:15 — burned the toast, started over." The diaries are logs. When something goes wrong, you check the screens for *what* happened (CPU spiked) and the diaries for *why* (error at 10:15). Loki is the librarian who finds the right diary fast.

Key terms:
- **Metrics**: numbers, aggregatable, time-series (Prometheus)
- **Logs**: text, event-based, detailed (Loki / `kubectl logs`)
- **Dashboard**: the wall of screens
- **Query**: asking "show me CPU for pod X in the last hour"

---

## Live demo script

**Step 1: Confirm everything is running**

```bash
make status
```

**Step 2: Open Grafana**

```bash
make demo
```

Navigate to Grafana (typically `http://localhost:3000`). Login with default credentials if prompted (often `admin/admin` or as configured).

**Step 3: Show the Pulse dashboard**

In Pulse app (`http://localhost:8080` or as shown), submit some jobs:

```bash
# Or use the web UI
curl -X POST http://localhost:8080/api/jobs -d '{"type":"render"}'
```

Back in Grafana, show:
- The pre-built Pulse dashboard
- CPU and memory graphs climbing
- Pod count if HPA is configured

Explain: Prometheus scraped these numbers. Grafana is the display.

**Step 4: Show raw metrics**

```bash
kubectl get svc -n monitoring
# Find Prometheus port, or:
kubectl port-forward svc/prometheus -n monitoring 9090:9090
```

Open `http://localhost:9090`, enter query:

```promql
rate(container_cpu_usage_seconds_total[5m])
```

This is the raw data. Grafana makes it pretty.

**Step 5: Show logs**

```bash
kubectl logs -n pulse deployment/pulse --tail=20
```

Then show Loki in Grafana:
- Explore → Loki datasource
- Query: `{app="pulse"}`
- Add filters: `|= "error"` or `|= "render"`

Contrast: metrics told us CPU spiked at 10:15. Logs told us a render job failed at 10:15:03.

---

## Classroom exercise

Direct students to `docs/labs/05-read-the-logs`:

- Find a specific error in Pulse logs using Loki
- Correlate it with a CPU spike on the Grafana dashboard
- Bonus: create a simple Grafana panel showing request rate

---

## Discussion questions

1. When would metrics mislead you? (e.g., CPU normal but memory exhausted)
2. Why store logs centrally (Loki) instead of just `kubectl logs`?
3. What's missing from this observability stack? (Traces/distributed tracing — mention if time permits)
4. How long should you keep logs? Who decides?

---

## Common student questions & answers

**Q: Does Prometheus store data forever?**  
A: No — typically 15 days by default. For long-term storage, you'd use Thanos or Cortex.

**Q: Why is my Grafana empty?**  
A: Check `make status`. Prometheus may not be scraping yet, or the dashboard import failed. Try `kubectl rollout restart deployment/prometheus -n monitoring`.

**Q: What's the difference between Loki and ELK?**  
A: Loki is lightweight, index-free (labels only), designed for Kubernetes. ELK is more powerful but heavier. For teaching, Loki is "just enough."

**Q: Can I alert from these metrics?**  
A: Yes — Prometheus Alertmanager is the next step. Mention it; don't demo unless time permits.

---

## Time breakdown

| Segment | Time |
|---------|------|
| Story & concepts | 10 min |
| Live demo | 15 min |
| Student exercise | 15 min |
| Discussion & wrap | 5 min |