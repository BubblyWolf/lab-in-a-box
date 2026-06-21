# Module 5 — Automation & supply chain

**Tool focus**: GitHub Actions, Cosign, Trivy, SBOM  
**Estimated time**: 45 minutes

---

## Learning objectives

- Trace a code change through build, scan, sign, and deploy stages
- Explain why signed images and SBOMs matter for supply chain security
- Identify which CI/CD step catches which category of problem

---

## The story to tell

Open `docs/concepts.md` and walk through the **assembly line + health inspector stamping each dish** analogy.

> The kitchen used to be chaos: one cook preps, another grills, someone forgets the order. Now there's an assembly line: prep → grill → plate → serve. Each station checks the work before passing it on. The health inspector stamps each dish: "inspected, safe to eat." If a customer gets sick, you trace the stamp back to the exact station and time. GitHub Actions is the assembly line. Trivy is the ingredient check. Cosign is the stamp. The SBOM is the ingredient list on the back of the package.

Key terms:
- **CI/CD**: continuous integration (build, test) and continuous deployment (release)
- **SBOM**: software bill of materials — the ingredient list
- **Image signing**: cryptographic proof of who built it and that it hasn't been tampered with
- **Supply chain**: everything from code to running container

---

## Live demo script

**Step 1: Open the workflow**

```bash
cat .github/workflows/ci.yml
```

Or open in GitHub web UI for better formatting.

**Step 2: Walk through each step**

Read the file top-to-bottom:

This is the shape of the real file (`.github/workflows/ci.yml`) — open the actual file alongside it:

```yaml
name: CI

on:
  push:
    branches: [main]
    tags: ['v*']

permissions:
  contents: read
  packages: write       # push images to GHCR
  id-token: write       # keyless signing with cosign

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        service: [api, worker, frontend]   # build all 3 Pulse services
    steps:
      - uses: actions/checkout@v4
      - uses: docker/build-push-action@v6   # build + push the image
        with:
          context: apps/demo/${{ matrix.service }}
          push: true
          tags: ghcr.io/<owner>/pulse-${{ matrix.service }}:${{ github.sha }}

      - name: Install Trivy            # the health inspector
        run: curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
      - name: Trivy scan
        run: trivy image --format sarif --output trivy.sarif <image>

      - uses: anchore/sbom-action@v0    # generate an SBOM (ingredient list)
      - uses: sigstore/cosign-installer@v3
      - run: cosign sign --yes <image>  # tamper-proof signature
```

> Teaching note: we install the Trivy CLI directly rather than a third-party action — a good real-world lesson that pinned action versions/transitive dependencies can break, and sometimes the simplest, self-contained step is the most reliable.

**Step 3: Show the live pipeline**

Open the repository in GitHub → Actions tab. Show:
- Green checkmark on latest run
- Click into a run → each step's logs
- The Trivy scan results (vulnerabilities found or "clean")
- The SBOM artifact attached to the run
- The signed image reference in the registry

```bash
# Verify signature locally if registry is accessible
cosign verify pulse:latest --certificate-identity-regexp=.* --certificate-oidc-issuer-regexp=.*
# Adjust flags to your trust policy
```

**Step 4: Show the connection to Module 1**

Argo CD deploys from Git. But what ensures the *image* in Git is trustworthy? The CI pipeline. This closes the loop: code → signed image → Git references it → Argo CD deploys it.

---

## Classroom exercise

**Option A: Read and explain**

Students read `.github/workflows/ci.yml` and annotate each step:
- "This step catches..."
- "If this fails, the next step won't run because..."

**Option B: Break and fix**

Teacher provides a broken workflow (e.g., scan happens *after* push, or signing uses wrong key). Students identify and fix.

**Option C: Add a step**

Students add a step: run tests, lint Dockerfile, or notify Slack. Test with `act` locally if available, or discuss what would happen.

---

## Discussion questions

1. Why sign an image if the registry is private and trusted?
2. Who should have access to the signing key? Where is it stored?
3. An SBOM for a base image lists 500 packages. Is that useful or noise?
4. If Trivy finds a CRITICAL vulnerability in a dependency you don't directly use, what do you do?

---

## Common student questions & answers

**Q: What's the difference between Cosign and Notary?**  
A: Both sign images. Cosign (Sigstore) is newer, simpler, and uses keyless signing with OIDC. Notary is Docker's older solution. This course uses Cosign.

**Q: Can I run this CI locally?**  
A: Partially — `act` runs GitHub Actions locally. But signing needs the OIDC provider or a stored key. For class, focus on reading and understanding, not executing.

**Q: Why does the SBOM matter if I already scan for vulnerabilities?**  
A: Scanning finds *known* vulnerabilities. The SBOM lets you respond to *newly discovered* ones by knowing exactly what you shipped. It's also required by some compliance frameworks.

**Q: Does this pipeline deploy automatically?**  
A: It builds and signs. Deployment to the cluster may be separate (GitOps-style) or a final "deploy" job. In this course, Argo CD handles deployment; CI handles everything up to "ready to deploy."

---

## Time breakdown

| Segment | Time |
|---------|------|
| Story & concepts | 10 min |
| Live demo | 15 min |
| Student exercise | 15 min |
| Discussion & wrap | 5 min |