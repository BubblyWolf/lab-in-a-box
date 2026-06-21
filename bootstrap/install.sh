#!/usr/bin/env bash
# lab-in-a-box bootstrap installer
# MIT License | Copyright (c) 2026 Chitranjan Jegadeesan

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

echo -e ""
echo -e "🧪 ${GREEN}lab-in-a-box${NC} Bootstrap Installer"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e ""

# ─────────────────────────────────────────────────────────
# Step 1: Wait for cluster nodes to be Ready
# ─────────────────────────────────────────────────────────
echo -e "⏳ Waiting for cluster nodes to be Ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=120s
echo -e "  ${GREEN}✓${NC} All nodes are Ready"
echo -e ""

# ─────────────────────────────────────────────────────────
# Step 1b: Install metrics-server (needed for autoscaling / HPA)
# Kind nodes use self-signed kubelet certs, so we add --kubelet-insecure-tls.
# ─────────────────────────────────────────────────────────
echo -e "📈 Installing metrics-server (powers autoscaling)..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml >/dev/null
kubectl patch deployment metrics-server -n kube-system --type=json \
  -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]' >/dev/null 2>&1 || true
echo -e "  ${GREEN}✓${NC} metrics-server installed"
echo -e ""

# ─────────────────────────────────────────────────────────
# Step 2: Install Argo CD (idempotent)
# ─────────────────────────────────────────────────────────
echo -e "🔧 Installing Argo CD..."
if kubectl get namespace argocd &>/dev/null; then
    echo -e "  ${YELLOW}⚠${NC}  Namespace 'argocd' already exists, skipping namespace creation"
else
    kubectl create namespace argocd
    echo -e "  ${GREEN}✓${NC} Created namespace 'argocd'"
fi

# Apply Argo CD stable manifests (idempotent via server-side apply)
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml >/dev/null

echo -e "  ${GREEN}✓${NC} Argo CD manifests applied"
echo -e ""

# ─────────────────────────────────────────────────────────
# Step 3: Wait for Argo CD server to be available
# ──────────────────────────────────────────────────────────
echo -e "⏳ Waiting for Argo CD server to be available..."
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=180s
echo -e "  ${GREEN}✓${NC} Argo CD server is ready"
echo -e ""

# ─────────────────────────────────────────────────────────
# Step 4: Apply GitOps root application (if exists)
# ─────────────────────────────────────────────────────────
echo -e "🌱 Configuring GitOps root application..."
readonly ROOT_APP_PATH="gitops/bootstrap/root-app.yaml"

if [[ -f "${ROOT_APP_PATH}" ]]; then
    kubectl apply -f "${ROOT_APP_PATH}"
    echo -e "  ${GREEN}✓${NC} Applied root application from ${ROOT_APP_PATH}"
else
    echo -e "  ${YELLOW}⚠${NC}  Root app not found at ${ROOT_APP_PATH}"
    echo -e "      ${BLUE}ℹ${NC}  Skipping GitOps bootstrap. Create ${ROOT_APP_PATH} and re-run 'make up' to enable."
fi
echo -e ""

# ───────────────────────────────────────────────────────────
# Step 5: Print access information
# ─────────────────────────────────────────────────────────
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "🎉 ${GREEN}Bootstrap complete!${NC}"
echo -e ""
echo -e "🔐 Argo CD Access:"
echo -e "   URL:      ${BLUE}https://localhost:8080${NC} (run 'make demo' to port-forward)"
echo -e "   Username: ${YELLOW}admin${NC}"
echo -e ""
echo -e "   To get the admin password, run:"
echo -e "   ${YELLOW}kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d${NC}"
echo -e ""
echo -e "📚 Next steps:"
echo -e "   • make status  — Check cluster health"
echo -e "   • make demo    — Open ArgoCD and Grafana in browser"
echo -e "   • make down    — Tear down the cluster"
echo -e ""