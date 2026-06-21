# Module 1 — GitOps & how apps deploy themselves

**Tool focus**: Argo CD, Kind, Helm  
**Estimated time**: 45 minutes

---

## Learning objectives

- Define GitOps: the single source of truth is Git, and the system makes reality match it
- Observe Argo CD automatically deploy an application and self-heal when drift occurs
- Run basic commands to check application status in Kubernetes

---

## The story to tell

Open `docs/concepts.md` and walk through the **manager + recipe book** analogy.

> The restaurant manager keeps the master recipe book. Every morning, the kitchen staff set up stations exactly to the recipes. If a cook moves a pan to the wrong shelf, the manager notices and puts it back. The recipe book is the source of truth; the kitchen is the live state. Argo CD is that manager, constantly comparing the live cluster to the Git repository.

Key terms to introduce:
- **Desired state** (the recipe)
- **Live state** (the kitchen right now)
- **Sync** (making them match)
- **Self-healing** (putting the pan back when someone moves it)

---

## Live demo script

**Step 1: Start the cluster** (skip if already running from `make up`)

```bash
make up
make status
```

**Step 2: Open Argo CD**

```bash
make demo
```

This opens browser tabs. Focus on Argo CD (typically `https://localhost:8080` or as shown). Login: `admin` / get password with:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

**Step 3: Show the Pulse app**

```bash
make deploy-local
```

In Argo CD UI, show:
- The `pulse` application tile
- "Sync status: Synced"
- Resource tree: Deployment, Service, Pods

**Step 4: Make a change and watch self-healing**

In a new terminal, scale the deployment manually (simulating a human or bug changing live state):

```bash
kubectl scale deployment pulse --replicas=5 -n pulse
```

Back in Argo CD, refresh the app. Watch it detect "OutOfSync." Within ~3 minutes, or after manual sync, it scales back to the value in Git.

Point out: Argo CD *reverted* our manual change. The recipe book won.

**Step 5: Show the Git repository**

```bash
# Show where Argo CD is looking
kubectl get application pulse -n argocd -o yaml | grep repoURL -A 2
```

Open that repo path. Show `gitops/apps/pulse.yaml` (the Argo CD Application) and `charts/pulse/` (the Helm chart it points to) — together these are the YAML "recipe book" that is the single source of truth.

---

## Classroom exercise

Direct students to:
- `docs/labs/01-first-launch` — get Pulse running, check Argo CD
- `docs/labs/02-scale-and-heal` — modify replicas in Git, watch Argo CD sync

Students work in pairs. Teacher circulates and verifies Argo CD shows "Synced" green tiles.

---

## Discussion questions

1. What happens if someone edits the cluster directly with `kubectl` and never updates Git?
2. Why might a team want the *recipe book* to be the only place changes happen?
3. When would you *not* want automatic self-healing?
4. How is this different from traditional "run a script to deploy"?

---

## Common student questions & answers

**Q: Do I need to push to GitHub for Argo CD to see it?**  
A: No — this course uses a local path or local Git server. In production, yes, you'd use a real repository.

**Q: What if the Git repo has a mistake?**  
A: Argo CD will try to sync the mistake. That's why CI/CD (Module 5) validates changes *before* they reach the main branch.

**Q: Can I use Argo CD with Helm?**  
A: Yes — and you'll see that in Module 2. The Pulse app is already deployed via Helm chart.

**Q: Why does self-healing take a few minutes?**  
A: Argo CD polls Git on an interval (default 3 minutes). You can click "Refresh" or "Sync" manually in the UI.

---

## Time breakdown

| Segment | Time |
|---------|------|
| Story & concepts | 10 min |
| Live demo | 15 min |
| Student lab time | 15 min |
| Discussion & wrap | 5 min |