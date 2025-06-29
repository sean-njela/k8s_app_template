#!/usr/bin/env bash
# scripts/k3s-init.sh
# -----------------------------------------------------------------------------
# Creates a throwaway k3d cluster named 'k3s-dev' matching the pod/service CIDRs
# of GKE Autopilot to avoid surprises.
# -----------------------------------------------------------------------------
set -euo pipefail

CLUSTER_NAME="k3s-dev"
POD_CIDR="10.48.0.0/14"
SVC_CIDR="10.52.0.0/20"

if command -v k3d &>/dev/null; then
  echo "🚀 Creating k3d cluster $CLUSTER_NAME…"
  k3d cluster create "$CLUSTER_NAME" \
    --agents 1 \
    --k3s-arg "--cluster-cidr=$POD_CIDR@server:0" \
    --k3s-arg "--service-cidr=$SVC_CIDR@server:0" \
    --port "8080:80@loadbalancer" \
    --wait
  echo "✅ k3d cluster ready. Context: k3d-$CLUSTER_NAME"
else
  echo "💥 k3d not installed. See https://k3d.io/#installation" >&2
fi