
# Contributing to lab-in-a-box

Thanks for your interest! This project is built for learning and sharing. Whether you're fixing a typo, adding a new exporter, or hardening a policy — all contributions are welcome.

---

## Getting Started

### Prerequisites

Same as [README.md](../README.md#prerequisites): Docker, kubectl, kind, helm.

### Local Development Setup

```bash
# 1. Fork and clone your fork
git clone https://github.com/YOUR_USERNAME/lab-in-a-box.git
cd lab-in-a-box

# 2. Create a branch
git checkout -b feature/your-feature-name

# 3. Start the stack
make up
make deploy-local

# 4. Verify everything works
make test
make demo
```

### Project Structure for Contributors

| Directory | What to change |
|-----------|--------------|
| `apps/demo/` | Demo app code (Node.js: api, worker, frontend) |
| `apps/` | Argo CD Application manifests |
| `monitoring/` | Dashboards, alerts, scrape configs |
| `security/` | Kyverno policies, sealed secrets examples |
| `ci/` | GitHub Actions workflow definitions |
| `cluster/` | Kind configuration, bootstrap scripts |
| `docs/` | Documentation |

---

## PR Validation

All pull requests run these checks automatically via GitHub Actions. You can run them locally:

```bash
# Validate Kubernetes manifests
make lint

# Specific checks:
helm lint pulse/helm/                    # Helm chart syntax
helm template pulse/helm/ | kubeconform  # Schema validation
kubectl apply --dry-run=client -f apps/  # K8s API validation

# Smoke test (requires running cluster)
make test

# Security policy validation
kyverno test security/policies/
```

### Required checks before PR

- [ ] `make lint` passes
- [ ] `make test` passes (or explain why not applicable)
- [ ] New policies include test cases in `security/policies/_tests/`
- [ ] Dashboards exported as JSON and placed in `monitoring/grafana/dashboards/`
- [ ] Documentation updated if behavior changes

---

## Commit Style

We use conventional commits for clear history and automatic changelog generation:

```
type(scope): subject

body (optional)

footer (optional)
```

| Type | Use for |
|------|---------|
| `feat` | New capability, tool, or service |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no code change |
| `refactor` | Code change, same behavior |
| `test` | Adding or correcting tests |
| `chore` | Maintenance, dependencies |

Examples:
```
feat(monitoring): add worker queue depth panel to Pulse dashboard
fix(security): allow istio-init container in disallow-root policy
docs: clarify sealed secrets workflow in runbook
```

---

## Code of Conduct

### Our standards

- **Be respectful**: Disagreement is fine; disrespect is not.
- **Assume good intent**: Most confusion comes from context, not malice.
- **Help others learn**: Explain the "why" in reviews, not just the "what."
- **Credit generously**: If you build on someone's idea, acknowledge it.

### Unacceptable behavior

Harassment, discrimination, trolling, or sustained disruption of discussion. This includes sexualized language, personal attacks, and publishing private information.

### Reporting

Contact [Chitranjan Jegadeesan](https://github.com/BubblyWolf) directly, or open a private issue if you prefer. All reports are handled confidentially.

---

## Ideas and Feedback

Not ready to code? We still want to hear from you:

- **Open an issue** for bugs, unclear docs, or feature requests
- **Start a discussion** for questions, show-and-tell, or architecture debates
- **Star the repo** if it's useful — it helps others find it

### Good first issues

Look for issues labeled `good first issue` or `help wanted`. These are vetted for clear scope and mentor availability.

---

## Development Tips

### Fast iteration cycle

```bash
# Rebuild and reload only the changed component
# Example: update API code
cd pulse/api
docker build -t pulse-api:local .
kind load docker-image pulse-api:local --name lab-in-a-box
kubectl rollout restart deployment/pulse-api -n pulse

# Or use tilt for automatic rebuilds (optional)
# https://tilt.dev/
```

### Testing policy changes

```bash
# Add test case first
cat > security/policies/_tests/test-my-policy.yaml << 'EOF'
name: test-my-policy
policies:
  - require-labels.yaml
resources:
  - resource-without-labels.yaml
results:
  - policy: require-labels
    rule: check-labels
    resource: bad-deployment
    kind: Deployment
    result: fail
EOF

# Run test
kyverno test security/policies/_tests/
```

### Adding a new Grafana dashboard

1. Build dashboard in Grafana UI at http://localhost:3000
2. Export as JSON (share icon → Export → Save to JSON)
3. Place in `monitoring/grafana/dashboards/`
4. Update `monitoring/grafana/dashboard-configmap.yaml` if needed
5. Verify with `make up` that dashboard loads automatically

---

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

*Questions? Open an issue or reach out. We're building this together.*
