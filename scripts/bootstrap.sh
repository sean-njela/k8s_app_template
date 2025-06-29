#!/usr/bin/env bash
# scripts/bootstrap.sh
# -----------------------------------------------------------------------------
# One‑time bootstrap for a **new** GKE Autopilot cluster:
#   1) Installs Argo CD via Helm
#   2) Applies the platform root Application (app‑of‑apps)
# -----------------------------------------------------------------------------
set -euo pipefail

NAMESPACE="argocd"
ARGO_CHART_VERSION="6.9.2"
REPO_ROOT=$(git rev-parse --show-toplevel)

if [[ -z "${KUBECONFIG:-}" ]]; then
  echo "💥 KUBECONFIG not set. Run 'gcloud container clusters get-credentials …' first." >&2
  exit 1
fi

# 1. Install Argo CD (with minimal values)
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm upgrade --install argocd argo/argo-cd \
  --namespace "$NAMESPACE" --create-namespace \
  --version "$ARGO_CHART_VERSION" \
  --set server.service.type=LoadBalancer \
  --set configs.cm."accounts\.admin"="apiKey"

echo "🕒 Waiting for Argo CD server to be Ready…"
kubectl wait --namespace "$NAMESPACE" --for=condition=available deploy/argocd-server --timeout=300s

# 2. Apply bootstrap manifests
kubectl apply -f "$REPO_ROOT/bootstrap/argocd/projects/default.yaml"
kubectl apply -f "$REPO_ROOT/bootstrap/argocd/app-of-apps.yaml"

echo "✅ Cluster bootstrapped! Open the Argo CD UI and watch apps sync."