# Lab-in-a-Box: Teacher's Guide

A ready-to-teach course on DevOps and cloud-native concepts. You don't need to be a Kubernetes expert to run this. Everything you need is in the box.

---

## Who this course is for

- **Students**: Developers, sysadmins, or curious technologists who want hands-on experience with modern cloud-native tooling. No prior Kubernetes experience required.
- **Teachers**: Lecturers, workshop facilitators, or team leads who want to run a practical DevOps course without building infrastructure from scratch.

## What students will be able to do by the end

By the end of this course, students can:

- Explain what GitOps is and why it beats manual deployment
- Deploy and update applications using Argo CD and Helm
- Read container metrics and logs to diagnose real problems
- Apply security guardrails that prevent bad deployments
- Trace code from commit to signed, scanned image in a CI/CD pipeline

## The five modules at a glance

| Module | Theme | Duration | Key tools |
|--------|-------|----------|-----------|
| [Module 1: GitOps & how apps deploy themselves](module-1-gitops.md) | Argo CD, declarative configuration, self-healing | ~45 min | Argo CD, Kind, Helm |
| [Module 2: Containers, images & Helm](module-2-containers-helm.md) | Docker, images, charts, templating | ~45 min | Docker, Helm |
| [Module 3: Seeing inside the system](module-3-observability.md) | Metrics, logs, dashboards | ~45 min | Prometheus, Grafana, Loki |
| [Module 4: Security & guardrails](module-4-security.md) | Policies, scanning, secrets | ~45 min | Kyverno, Trivy, Sealed Secrets |
| [Module 5: Automation & supply chain](module-5-cicd.md) | CI/CD, signing, SBOMs | ~45 min | GitHub Actions, Cosign, Trivy |

## Before class: one setup command

Each student needs a machine with Docker, Kind, and `make` installed. Then:

```bash
make up
```

This creates a local Kubernetes cluster and installs all tools. Verify with:

```bash
make status
```

For a shared demo machine, the teacher runs `make up` once and students observe via screen share or `kubectl` access.

## Suggested formats

**Single 3-hour workshop**
- 15 min: intro, `make up`, and concepts overview
- 45 min: Module 1 (GitOps)
- 15 min: break
- 45 min: Module 2 (Containers & Helm)
- 30 min: lunch
- 45 min: Module 3 (Observability) — or skip to 4 if pressed
- 45 min: Module 4 (Security) or Module 5 (CI/CD)

**Five weekly 45-minute sessions**
- Week 1: Module 1
- Week 2: Module 2
- Week 3: Module 3
- Week 4: Module 4
- Week 5: Module 5 + student presentations

## Assessment ideas

- **Lab completion**: Students finish all five labs and show `make status` output
- **Break-and-fix**: Give students a misconfigured chart or blocked deployment; they diagnose and repair
- **Concept explanation**: Students explain one concept from `docs/concepts.md` to a peer using the restaurant analogy
- **Portfolio**: Students keep their running Navidrome instance (`make music`) and document their setup

## Your secret weapon: the story book

Every concept in this course has a beginner-friendly story in [`docs/concepts.md`](../concepts.md). The restaurant analogy (kitchen, manager, recipes, scaling) is your bridge between "why" and "how." Use it when students look confused. The glossary is there for quick reference.

---

## Quick command reference for teachers

| Command | What it does |
|---------|-------------|
| `make up` | Start the cluster and install everything |
| `make down` | Tear it all down |
| `make status` | Check what's running |
| `make deploy-local` | Deploy the Pulse demo app |
| `make music` | Deploy Navidrome (student keeps this!) |
| `make demo` | Open UIs: Argo CD, Grafana, etc. |

---

Questions? Check the [lab directory](../labs/) for student-facing instructions. You've got this.