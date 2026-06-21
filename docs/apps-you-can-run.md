# 🧩 Apps you can run on lab-in-a-box

**Navidrome is just one example.** The whole point of a platform like Kubernetes is that it can run *almost any* containerised app the same way. Once you understand how Navidrome is deployed (a Helm chart + an Argo CD Application), you can deploy hundreds of real, open-source apps with the exact same pattern.

Think of the platform as the **restaurant building** — Navidrome is one dish we put on the menu to show how it works. Here are many more dishes you could serve.

> 💡 All of these are **free and open-source**, and self-hosted means *your* data stays on *your* machine. Where the app handles media (music, movies, photos), you supply your own files — so it's completely legal to use and keep.

---

## 🟢 Light — comfortable on a laptop

These are small and run happily inside your local Kind cluster.

| App | The story (what it is) | Like… |
|-----|------------------------|-------|
| **Navidrome** ✅ *(included)* | Stream your own music collection from a clean web player | Spotify |
| **Uptime Kuma** | A pretty dashboard that pings your websites and alerts you when they go down | A status page |
| **PairDrop** | Send files between your phone and laptop straight through the browser | AirDrop |
| **Vaultwarden** | A private vault for all your passwords, synced across devices | Bitwarden / 1Password |
| **Memos** | Jot quick notes and thoughts in a simple timeline | A personal Twitter |
| **Linkding** | Save and organise your bookmarks in one searchable place | Pocket / Raindrop |
| **Excalidraw** | Sketch diagrams and ideas on a shared whiteboard | A digital whiteboard |
| **Stirling-PDF** | Merge, split, sign, and convert PDFs in your browser | A PDF toolkit |

---

## 🟡 Medium — fine on a decent machine (8 GB+ RAM)

A bit heavier, but still great for learning and real use.

| App | The story (what it is) | Like… |
|-----|------------------------|-------|
| **Gitea** / **Forgejo** | Host your own Git repositories with issues and pull requests | A private GitHub |
| **FreshRSS** | Follow all your news and blogs in one feed reader | Google Reader |
| **Paperless-ngx** | Scan and search all your documents and receipts | A smart filing cabinet |
| **n8n** | Wire apps together to automate boring tasks, no code needed | Zapier |
| **Linkwarden** | Save web pages and articles to read later, with full-text search | Pocket pro |

---

## 🔴 Heavier — needs more RAM/CPU (may strain a small laptop)

Powerful, popular apps — best on a machine with plenty of memory, or a real server later.

| App | The story (what it is) | Like… |
|-----|------------------------|-------|
| **Jellyfin** | Stream your own movies, TV, and music to any device | Netflix / Plex |
| **Nextcloud** | Your own cloud for files, calendar, contacts, and notes | Google Drive / Dropbox |
| **Immich** | Back up and browse your photos and videos with AI search | Google Photos |
| **Mastodon** | Run your own corner of the social web | Twitter / X |

---

## 🛠️ How you'd actually deploy any of them

The pattern is always the same — and you already have a working template in this repo:

1. **Find the app's image or Helm chart.** Most of these publish an official Docker image, and many have a community Helm chart.
2. **Wrap it like we wrapped Navidrome.** Copy [`charts/navidrome/`](../charts/navidrome/) as a starting point — adjust the image, ports, volumes, and environment variables.
3. **Add a GitOps Application.** Drop a manifest in [`gitops/apps/`](../gitops/apps/) (copy [`gitops/apps/navidrome.yaml`](../gitops/apps/navidrome.yaml)) so Argo CD deploys it automatically.
4. **Keep it secure.** Make it run non-root (set a `securityContext`) so it passes the Kyverno policies — just like Navidrome does. That's the real-world habit this lab teaches.

> 🎓 **This is the skill that matters.** Companies don't pay you to run *one specific app* — they pay you to run *any* app reliably, securely, and automatically. Deploying a few of these yourself is exactly that skill, practised for free on your laptop.

---

## 🚀 Try it as a challenge

Pick a 🟢 light app from the list and deploy it yourself using the Navidrome chart as a template. When it works, you've proven you can put **any** real app on a production-style platform. (Stuck? Open an issue — we're happy to help.)
