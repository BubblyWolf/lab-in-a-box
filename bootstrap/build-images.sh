#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration (override via environment variables)
# -----------------------------------------------------------------------------
CLUSTER_NAME="${CLUSTER_NAME:-lab-in-a-box}"
IMAGE_PREFIX="${IMAGE_PREFIX:-ghcr.io/bubblywolf}"

# Services to build
SERVICES=("api" "worker" "frontend")

# -----------------------------------------------------------------------------
# Pre-flight checks
# -----------------------------------------------------------------------------
echo "🔍 Pre-flight checks..."

if ! command -v docker &> /dev/null; then
    echo "❌ docker is required but not installed. Aborting." >&2
    exit 1
fi

if ! command -v kind &> /dev/null; then
    echo "❌ kind is required but not installed. Aborting." >&2
    exit 1
fi

echo "✅ docker and kind are available"
echo "📦 Image prefix: ${IMAGE_PREFIX}"
echo "☸️  Cluster name: ${CLUSTER_NAME}"
echo ""

# -----------------------------------------------------------------------------
# Build and load images
# -----------------------------------------------------------------------------
for svc in "${SERVICES[@]}"; do
    image="${IMAGE_PREFIX}/pulse-${svc}:latest"
    build_context="apps/demo/${svc}"

    echo "🏗️  Building image for ${svc}..."
    echo "   Context: ${build_context}"
    echo "   Tag: ${image}"

    docker build -t "${image}" "${build_context}"

    echo "⬆️  Loading ${image} into kind cluster '${CLUSTER_NAME}'..."
    kind load docker-image "${image}" --name "${CLUSTER_NAME}"

    echo "✅ ${svc} complete!"
    echo ""
done

echo "🎉 All images built and loaded successfully!"
echo ""
echo "📋 Loaded images:"
for svc in "${SERVICES[@]}"; do
    echo "   - ${IMAGE_PREFIX}/pulse-${svc}:latest"
done