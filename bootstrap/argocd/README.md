# bootstrap/argocd/ – GitOps Bootstrap for a Fresh Cluster

These manifests turn an empty GKE Autopilot cluster into a fully‑managed platform.We install Argo CD once, then bootstrap everything else via an “app‑of‑apps” pattern.

Why this structure?Separation of concerns (projects vs. applications), least‑privilege RBAC, and crystal‑clear audit trails—all using plain YAML a newcomer can read.

```
bootstrap/argocd/
├── README.md            # Step‑by‑step bootstrap guide (below)
├── app-of-apps.yaml     # Root Application – seeds all other apps
├── projects/
│   └── default.yaml     # Argo CD AppProject with safe defaults
└── applications/        # One Application per addon (Helm charts)
    ├── cert-manager.yaml
    ├── traefik.yaml
    ├── linkerd.yaml
    ├── observability.yaml
    ├── gatekeeper.yaml
    └── falco.yaml
```
---
## Argo CD Bootstrap – Quick Start

### Prerequisites
1. A working `kubectl` context pointing to your GKE Autopilot cluster.
2. Helm ≥ 3.15 (for initial Argo CD install) **or** simply `kubectl apply` the upstream YAML.

### Step 0 Install Argo CD core
```bash
# Create namespace & install Argo CD via official chart (lightweight default values)
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  --version 6.9.2 \
  --set server.service.type=LoadBalancer \
  --set configs.cm."accounts\.admin"="apiKey"

# Wait for pods (≈2 min) then login once to set a password OR create an API token.
```

### Step 1 Apply the GitOps root (this folder)

```bash
# Clone your repo & apply the root Application and supporting objects
kubectl apply -f bootstrap/argocd/projects/default.yaml
kubectl apply -f bootstrap/argocd/app-of-apps.yaml

# Argo CD now owns its own configuration. Future changes go through Git.
```

---

### Step 2 Watch it build itself

Open the Argo CD UI ➜ Applications tab.You should see cert‑manager → traefik → linkerd → observability →… installing in order.

> Troubleshooting: If an add‑on is stuck in "ImagePullBackOff", check your project’s Artifact Registry
>IAM or quarantined container registry mirrors often blocked in corporate networks.

---

## Application-of-applications
How it works: Argo CD monitors the bootstrap/argocd/applications/ folder at HEAD of main.  Each sub‑directory YAML becomes a child Application. When you git push, Argo CD syncs.

---

## applications/ – One YAML per Add‑on

Each file is essentially the same shape: install a Helm chart into its own namespace, automate sync & self‑heal.

All are template snippets—feel free to adjust chart versions, values, or add patches. All set syncPolicy.automated for hands‑off ops.

> Tip: Stick to explicit chart versions so upgrades are a conscious Git commit.

---

## observability.yaml (Grafana Alloy + Loki + Grafana)
Why inline chart from the same repo? Because Alloy + Loki needs opinionated config that is easier to track alongside code.

---

## How to add more add‑ons

1. Fork this pattern: one file ⇒ one Helm chart.
2. List the repo URL in projects/default.yaml → spec.sourceRepos.
3. Commit & let Argo CD self‑sync.