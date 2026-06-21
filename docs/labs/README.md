# Welcome to the lab-in-a-box learning labs

You've just found a local Kubernetes playground that fits on your laptop. These labs are your guided tour from "what's a pod?" to "I can debug apps, enforce security, and run my own services."

## Who these are for

- **Beginners**: you don't need to know Kubernetes already. We explain as we go.
- **Tinkerers**: if you like breaking things to see how they work, you'll feel at home.
- **Developers and ops folks**: refresh your skills in a safe, local environment.

## How to use these labs

Each lab is a short, self-contained story with a clear goal, numbered steps, and real commands you can copy-paste. Work through them in order, or jump to what interests you.

> **Tip**: keep a terminal open and a browser nearby. Most labs need both.

## Prerequisites

Before any lab, start the platform:

```bash
make up
```

This creates a local Kind cluster, installs Argo CD, monitoring, and security tooling. It takes a few minutes the first time.

When you're done for the day, clean up with:

```bash
make down
```

## Lab catalog

| # | Lab | Difficulty | Time | What you'll learn |
|---|-----|------------|------|-----------------|
| 01 | [Spin it up and look around](01-first-launch.md) | 🟢 easy | 15 min | Start the platform, deploy an app, find running pods |
| 02 | [Watch Kubernetes heal itself](02-scale-and-heal.md) | 🟢 easy | 20 min | Self-healing, scaling, and how Deployments work |
| 03 | [Meet the security guard](03-security-guard.md) | 🟡 medium | 25 min | Kyverno policies, blocked pods, writing compliant manifests |
| 04 | [Deploy your own music app](04-deploy-your-music.md) | 🟡 medium | 30 min | Run Navidrome, add music, keep a real app |
| 05 | [Become a detective with logs](05-read-the-logs.md) | 🟡 medium | 25 min | Read pod logs, correlate actions with output, explore Grafana |
| 06 | [Watch Kubernetes scale your app](06-autoscaling.md) | 🟡 medium | 25 min | Autoscaling under load — the "why Kubernetes vs Docker" moment |

## Stuck or curious?

Every lab has a collapsed solution section with hints and exact answers. Try the exercise yourself first — the struggle is where the learning happens.

Ready? Start with [lab 01](01-first-launch.md).