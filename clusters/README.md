# clusters/ – Environment‑specific Helmfile Deployments

These directories wire application releases to staging and production GKE clusters.  Each environment is completely declarative—no CLI flags required once the files are committed.

> Why Helmfile? It lets us pin chart versions, merge many values.yaml overrides, and run pre‑flight diffs—all in one place.

---

## Repository tree

```bash
clusters/
├── staging/
│   ├── helmfile.yaml          # All releases for the staging cluster
│   └── values/
│       └── webapp-values.yaml # Staging‑specific overrides
└── prod/
    ├── helmfile.yaml
    └── values/
        └── webapp-values.yaml
```
---

## Usage cheat‑sheet

```bash
# Set the image tag once (CI step)
export IMAGE_TAG=$(git rev-parse --short HEAD)

# Staging deploy
kubectl config use-context gke-staging
helmfile -f clusters/staging/helmfile.yaml sync

# Promote to prod after validation
kubectl config use-context gke-prod
helmfile -f clusters/prod/helmfile.yaml sync
```