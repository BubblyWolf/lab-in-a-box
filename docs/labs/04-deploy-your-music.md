# Lab 04 — Deploy your own music app

## The story

You've been managing demo apps. Now it's time to run something personal — a music server you can actually keep and use. Welcome Navidrome into your cluster, create your admin account, and hear your first note.

## Goal

Deploy Navidrome music server, open it in your browser, create an admin account, and add at least one playable track.

## Steps

### 1. Deploy Navidrome

```bash
make music
```

This installs the Navidrome chart into the `media` namespace and opens `http://localhost:4533`.

If the browser doesn't open automatically, navigate there manually.

### 2. Create your admin account

On first launch, Navidrome asks you to create an admin user. Choose a username and password you'll remember.

### 3. Add music

You have two options:

**Option A: Enable demo tracks (quickest)**

The Navidrome chart supports a `sampleMusic` option. Check if it's enabled in your deployment:

```bash
helm get values navidrome -n media
```

If not enabled, upgrade with demo tracks:

```bash
helm upgrade --install navidrome charts/navidrome -n media --set sampleMusic.enabled=true
```

Wait for the pod to restart, then refresh `http://localhost:4533`.

**Option B: Mount your own music**

For persistent music, place audio files in a directory and mount it. The chart supports configuring a persistent volume. Check `charts/navidrome/values.yaml` for the `persistence` section.

Example approach for local testing:

```bash
# Create a local music directory
mkdir -p ~/music-for-navidrome

# Copy an MP3, FLAC, or OGG file there
cp your-song.mp3 ~/music-for-navidrome/

# Upgrade with the local path (adjust based on your Kind setup)
helm upgrade --install navidrome charts/navidrome -n media \
  --set persistence.enabled=true \
  --set persistence.existingClaim=navidrome-music \
  --set extraVolumes[0].name=music \
  --set extraVolumes[0].hostPath.path=/home/your-user/music-for-navidrome \
  --set extraVolumeMounts[0].name=music \
  --set extraVolumeMounts[0].mountPath=/music
```

> Note: exact paths vary by OS. For Kind on Docker Desktop, you may need to share the folder in Docker settings first.

### 4. Scan and browse

In the Navidrome UI, go to **Settings** → **Scan**. Or wait for automatic scanning. Your tracks should appear in the library.

## ✅ How to check you did it

- `http://localhost:4533` loads and you can log in
- You see at least one album or track in the library
- You can press play and hear audio (or see the play button active)

## Keep experimenting

- Create a regular user account and try the mobile app (Navidrome has apps for iOS and Android)
- Check the pod: `kubectl get pods -n media`, `kubectl logs -n media -l app=navidrome`
- Explore the chart: `cat charts/navidrome/values.yaml | less`
- Try changing the theme or language in Navidrome settings

<details>
<summary>💡 Solution</summary>

**Verify the deployment:**

```bash
kubectl get pods -n media
kubectl get svc -n media
```

Expected output:

```
NAME                        READY   STATUS    RESTARTS   AGE
navidrome-7c4f9b8d5-x2k1m   1/1     Running   0          3m
```

**Enable demo tracks if needed:**

```bash
helm upgrade --install navidrome charts/navidrome -n media --set sampleMusic.enabled=true
kubectl rollout status deploy/navidrome -n media
```

Then refresh `http://localhost:4533` and check the library.

**Quick manual music mount (Docker Desktop / Linux):**

```bash
# 1. Create music folder in a Docker-shared location
mkdir -p ~/Music/navidrome
cp /path/to/your/music/*.mp3 ~/Music/navidrome/

# 2. Upgrade with hostPath (simplified; adjust for your environment)
helm upgrade --install navidrome charts/navidrome -n media \
  --set persistence.enabled=false \
  --set extraVolumes[0].name=music \
  --set extraVolumes[0].hostPath.path=/home/$USER/Music/navidrome \
  --set extraVolumeMounts[0].name=music \
  --set extraVolumeMounts[0].mountPath=/music
```

**Force a library scan:**

In the UI: Activity → Scan. Or check logs for scan activity:

```bash
kubectl logs -n media -l app=navidrome --tail=50
```

**Troubleshooting:**

| Problem | Check |
|---------|-------|
| `localhost:4533` refuses connection | `kubectl get svc -n media` — is port-forward active? Try `kubectl port-forward svc/navidrome 4533:4533 -n media` |
| Music not appearing | Verify file format (MP3, FLAC, OGG, M4A supported); check logs for scan errors |
| Pod not starting | `kubectl describe pod -n media -l app=navidrome` |

</details>