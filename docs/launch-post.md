
# Launch Post Drafts

Adapt these for your audience and platform. Keep the friendly, "built this to learn, sharing to help others" tone.

---

## Full Version (Blog / Dev.to / Hashnode)

---

### Title: Learn a real production Kubernetes platform by running one — offline, on your laptop, in 5 minutes

**TL;DR:** `lab-in-a-box` is a single-command, **fully offline** Kubernetes stack with GitOps, observability, security policies, and a full CI/CD pipeline — and a [guided walkthrough](https://github.com/BubblyWolf/lab-in-a-box/blob/main/docs/walkthrough.md) that *teaches* you each layer as it runs. No cloud, no bill. [github.com/BubblyWolf/lab-in-a-box](https://github.com/BubblyWolf/lab-in-a-box)

---

I wanted to understand how platform teams actually build and run things. Not just "hello world" Kubernetes — the real stuff: Argo CD syncing apps from Git, Prometheus scraping custom metrics, policies blocking bad deployments before they reach the cluster, CI pipelines that sign container images and generate SBOMs.

The problem? Doing this in the cloud costs money. Tutorials are fragmented. And you never see the *wiring* between tools.

So I spent weekends wiring everything together into one reproducible repo. Then I made it run locally with one command.

**What you get in 5 minutes:**

```bash
make up         # Kind cluster + Argo CD + Prometheus/Grafana/Loki + Kyverno
make deploy-local  # 3-microservice "Pulse" app with health checks and metrics
make demo       # Argo CD, Grafana, and the app — all open in browser
```

**The full stack:**

- ☸️ **Kind** — multi-node Kubernetes cluster in Docker
- 🔄 **Argo CD** — GitOps with app-of-apps pattern, Git as source of truth
- 📊 **Prometheus + Grafana + Loki** — custom "Pulse" dashboard, metrics-to-logs correlation
- 🔐 **Kyverno + Sealed Secrets + Trivy** — admission policies, encrypted secrets, vulnerability scanning
- 🚀 **GitHub Actions** — build, scan, SBOM, cosign sign, push to GHCR
- 🎯 **Pulse app** — Node.js API, worker, and frontend + Redis — all wired for observability

**Why this exists:**

It's a learning environment that doesn't lie. The policies actually block things. The dashboards show real data. The GitOps sync fails if you break the manifests. You can experiment, break, fix, and understand — without a $200 cloud bill or a 2am page.

**What I'd love:**

- ⭐ **Star it** if it saves you time or teaches you something
- 🍴 **Fork it** to build your own internal platform demo
- 💬 **Tell me** what you built, what broke, what I got wrong

Issues, ideas, and PRs welcome. This is a community learning project first.

---

## LinkedIn Variant

---

🧪 New project: I built a production-grade Kubernetes platform that runs entirely on my laptop — and I'm open-sourcing it.

**Why:** I was tired of fragmented tutorials and cloud bills just to learn how platform engineering actually works. I wanted to *run* GitOps, observability, and security policies — not just read about them.

**lab-in-a-box** gives you a full stack in one command:

- Kind cluster (Kubernetes in Docker)
- Argo CD GitOps with app-of-apps
- Prometheus/Grafana/Loki + custom dashboards
- Kyverno security policies + Sealed Secrets
- CI/CD with Trivy scanning, SBOMs, and cosign signing
- A working 3-microservice demo app with real metrics

`make up. make deploy-local. make demo.`

That's it. No cloud account. No surprise bill. Just learning.

If you're building platform skills, interviewing for SRE/DevOps roles, or teaching a team — this might save you weeks of setup.

🔗 [github.com/BubblyWolf/lab-in-a-box](https://github.com/BubblyWolf/lab-in-a-box)

Would love your feedback: what's missing? What should I add? What did you build with it?

---

## Reddit Variant (r/devops, r/kubernetes)

---

**[Showoff Saturday] lab-in-a-box: One-command local K8s platform with GitOps, observability, security**

Hey r/devops — spent my weekends building this and wanted to share.

**What:** Complete production platform stack running locally on Kind. Not a tutorial, not a Helm chart collection — everything actually wired together and working.

**Stack:**
- Kind (3-node cluster)
- Argo CD (app-of-apps, self-healing)
- Prometheus + Grafana + Loki (custom dashboard included)
- Kyverno policies (blocks bad pods at admission)
- Sealed Secrets + Trivy scanning + cosign signing
- Demo app: API + worker + frontend + Redis, all emitting metrics and logs

**The pitch:** `make up && make deploy-local && make demo` — 5 minutes to a working platform you can break and learn from. No cloud spend.

**Why I built it:** Interviewing for platform roles, I realized I could describe these tools but never *ran* them together. This fixes that.

**GitHub:** [github.com/BubblyWolf/lab-in-a-box](https://github.com/BubblyWolf/lab-in-a-box) (MIT licensed)

**What I'd actually like from you:**
- Try it, break it, tell me what broke
- What tool should I add next? (Vault? Linkerd? Crossplane?)
- If you're using it to learn or interview prep, how's it going?

Not trying to spam — genuinely want to make this better with the community.

---

## Hacker News Variant (concise, technical)

---

**Show HN: lab-in-a-box — production-grade K8s platform running locally**

One command to get: Kind cluster, Argo CD GitOps, Prometheus/Grafana/Loki observability, Kyverno policies, Sealed Secrets, Trivy scanning, and a working 3-service demo app with CI/CD (build, SBOM, cosign sign).

Built because I wanted to learn platform engineering without cloud bills. Everything is wired, not just installed.

`make up && make deploy-local`

[github.com/BubblyWolf/lab-in-a-box](https://github.com/BubblyWolf/lab-in-a-box)

---

## Twitter/X Variant

---

Built a thing: one-command local K8s platform with Argo CD, Grafana, Kyverno, Trivy, signed images — the whole production stack.

`make up. make demo. learn.`

No cloud. No bill. Just GitOps.

⭐ github.com/BubblyWolf/lab-in-a-box

What should I add next?

---

## Launch Checklist

- [ ] Post to personal blog / Dev.to / Hashnode
- [ ] Share on LinkedIn with personal story
- [ ] Post to r/devops, r/kubernetes, r/homelab
- [ ] Submit to HN Show HN
- [ ] Share in relevant Slack/Discord communities (Kubernetes, Argo, Platform Engineering)
- [ ] Tweet thread with screenshots/GIFs of `make up` → dashboards
- [ ] Follow up in 1 week with "what I learned from launch" post
