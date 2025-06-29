#!/usr/bin/env bash
# scripts/deploy.sh <dev|staging|prod>
# -----------------------------------------------------------------------------
# Convenience wrapper around helmfile to deploy the webapp chart to a chosen
# environment. Expects IMAGE_TAG env var (set by CI or manually).
# -----------------------------------------------------------------------------
set -euo pipefail

ENV=${1:-dev}
IMAGE_TAG=${IMAGE_TAG:-dev}

case "$ENV" in
  dev)
    KCTX="k3s-dev"
    HELMFILE_PATH="clusters/staging/helmfile.yaml"  # dev uses staging def w/ overrides
    ;;
  staging)
    KCTX="gke-staging"
    HELMFILE_PATH="clusters/staging/helmfile.yaml"
    ;;
  prod)
    KCTX="gke-prod"
    HELMFILE_PATH="clusters/prod/helmfile.yaml"
    ;;
  *)
    echo "Usage: $0 {dev|staging|prod}" >&2; exit 1 ;;
 esac

export IMAGE_TAG

echo "🔄 Switching context to $KCTX"
kubectl config use-context "$KCTX"

helmfile -f "$HELMFILE_PATH" sync