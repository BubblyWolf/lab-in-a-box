# lab-in-a-box: Local production-grade Kubernetes platform
# MIT License | Copyright (c) 2026 Chitranjan Jegadeesan

CLUSTER_NAME ?= lab-in-a-box

# Required tools
REQUIRED_TOOLS := kind kubectl helm

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

.PHONY: help up down status demo build-load deploy-local

help: ## Show this help message
	@echo ""
	@echo "🧪 $(GREEN)lab-in-a-box$(NC) — Local production-grade Kubernetes platform"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-12s$(NC) %s\n", $$1, $$2}'
	@echo ""

check-tools: ## Check that required tools are installed
	@for tool in $(REQUIRED_TOOLS); do \
		if ! command -v $$tool >/dev/null 2>&1; then \
			echo "$(RED)❌ Error: '$$tool' is not installed.$(NC)"; \
			echo ""; \
			echo "Please install the missing tool(s):"; \
			echo "  • kind:     https://kind.sigs.k8s.io/docs/user/quick-start/#installation"; \
			echo "  • kubectl:  https://kubernetes.io/docs/tasks/tools/"; \
			echo "  • helm:     https://helm.sh/docs/intro/install/"; \
			echo ""; \
			exit 1; \
		fi; \
	done
	@echo "$(GREEN)✓ All required tools found$(NC)"

up: check-tools ## 🚀 Create kind cluster and install platform
	@echo ""
	@echo "🧪 $(GREEN)lab-in-a-box$(NC): Starting up..."
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "📦 Creating Kind cluster '$(CLUSTER_NAME)'..."
	@kind create cluster --name $(CLUSTER_NAME) --config bootstrap/kind-config.yaml || echo "⚠️  Cluster may already exist, continuing..."
	@echo ""
	@echo "🏗️  Building and loading demo images into the cluster..."
	@bash bootstrap/build-images.sh
	@echo ""
	@echo "🔧 Running bootstrap installer (Argo CD + GitOps)..."
	@bash bootstrap/install.sh
	@echo ""
	@echo "$(GREEN)🎉 lab-in-a-box is up and running!$(NC)"
	@echo ""
	@echo "$(YELLOW)Tip:$(NC) GitOps (Argo CD) syncs from your pushed GitHub repo."
	@echo "     To run the demo locally WITHOUT pushing, use: $(YELLOW)make deploy-local$(NC)"
	@echo ""
	@echo "Run '$(YELLOW)make status$(NC)' to check health, or '$(YELLOW)make demo$(NC)' to access services."

build-load: check-tools ## 🏗️  Build demo images and load them into the kind cluster
	@bash bootstrap/build-images.sh

deploy-local: check-tools ## 📦 Install the Pulse chart directly via Helm (no GitHub push needed)
	@echo "📦 Installing Pulse chart into namespace 'pulse' (local, non-GitOps)..."
	@helm upgrade --install pulse charts/pulse --namespace pulse --create-namespace
	@echo "$(GREEN)✓ Pulse deployed.$(NC) Run '$(YELLOW)make demo$(NC)' for access info."

down: check-tools ## 💥 Delete the kind cluster
	@echo ""
	@echo "💥 $(YELLOW)Destroying lab-in-a-box cluster '$(CLUSTER_NAME)'...$(NC)"
	@kind delete cluster --name $(CLUSTER_NAME)
	@echo ""
	@echo "$(GREEN)✓ Cluster destroyed. Run 'make up' to recreate.$(NC)"

status: check-tools ## 📊 Show cluster and ArgoCD status
	@echo ""
	@echo "📊 $(GREEN)Cluster Status$(NC)"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "🖥️  Nodes:"
	@kubectl get nodes -o wide 2>/dev/null || echo "  (cluster not available)"
	@echo ""
	@echo "📦 ArgoCD Applications:"
	@kubectl get applications -n argocd 2>/dev/null || echo "  (ArgoCD not installed or no apps found)"
	@echo ""
	@echo "🔍 ArgoCD Server Pods:"
	@kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server 2>/dev/null || echo "  (ArgoCD server not found)"

demo: check-tools ## 🌐 Port-forward ArgoCD and Grafana, print access info
	@echo ""
	@echo "🌐 $(GREEN)Starting service port-forwards...$(NC)"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "🔐 ArgoCD credentials:"
	@echo "   Username: $(YELLOW)admin$(NC)"
	@echo "   Password: $(YELLOW)$$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' 2>/dev/null | base64 -d || echo '<not available>')$(NC)"
	@echo ""
	@echo "🚀 Starting port-forwards (Ctrl+C to stop)..."
	@echo ""
	@echo "   ArgoCD:         https://localhost:8080  (admin / password above)"
	@echo "   Grafana:        http://localhost:3000   (admin / admin)"
	@echo "   Pulse frontend: http://localhost:8081"
	@echo ""
	@kubectl port-forward svc/argocd-server -n argocd 8080:443 2>/dev/null & \
	ARGO_PID=$$!; \
	kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80 2>/dev/null & \
	GRAFANA_PID=$$!; \
	kubectl port-forward svc/pulse-frontend -n pulse 8081:3000 2>/dev/null & \
	PULSE_PID=$$!; \
	echo "Press Ctrl+C to stop all port-forwards"; \
	wait $$ARGO_PID $$GRAFANA_PID $$PULSE_PID 2>/dev/null; \
	echo ""; \
	echo "Port-forwards stopped."