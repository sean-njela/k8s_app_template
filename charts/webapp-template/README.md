# charts/webapp-template/ – Reusable Helm Chart for Any Web Service

This Helm chart provides a production‑grade, yet minimal blueprint for containerised web applications. It works unchanged across Dev → Staging → Prod because all env‑specific knobs live in the values‑*.yaml files referenced by Helmfile.

---

Key goals:

- Repeatable – sane defaults, deterministic rendering.
- Secure by default – runAsNonRoot, auto‑mount Linkerd annotations, automountServiceAccountToken: false.
- Kubernetes‑native best practices – readiness/liveness, PDB, HPA, metrics.
- Cloud‑agnostic – only standard K8s APIs + optional Traefik, ExternalSecrets CRDs.

---
## Repository tree

```
charts/webapp-template/
├── Chart.yaml           # Chart metadata (semver, appVersion)
├── values.yaml          # Opinionated defaults (override per env)
├── templates/
│   ├── _helpers.tpl     # Go template helpers (labels, annotations)
│   ├── deployment.yaml  # Core Deployment
│   ├── service.yaml     # ClusterIP Service
│   ├── ingress.yaml     # Traefik IngressRoute (optional)
│   ├── configmap.yaml   # App config (optional)
│   ├── externalsecret.yaml  # Pull secrets from Infisical
│   ├── hpa.yaml         # HorizontalPodAutoscaler
│   ├── pdb.yaml         # PodDisruptionBudget
│   ├── serviceaccount.yaml  # Dedicated SA
│   └── NOTES.txt        # Helm post‑install message
└── values-examples/     # Drop‑in overrides for common stacks
    ├── nodejs.yaml
    ├── django.yaml
    ├── react-spa.yaml
    └── golang.yaml
```
---

## values-examples/

Purpose: quick start overrides for common stacks. Example: nodejs.yaml
Replicate for Django, React SPA (static Nginx), Golang etc.

---

> Regarding templates/NOTES.txt: Helm prints the contents of this file after every helm install or helm upgrade. It’s a handy place for quick-start tips—URLs, curl commands to hit health endpoints, or reminders about ingress hosts and credentials. It never goes into the cluster; it’s purely for users at the CLI.

---

## Usage examples

Render with default values:

```
helm template myapp ./charts/webapp-template \
  --set image.tag=$(git rev-parse --short HEAD)
```

Or via Helmfile (preferred):

```
releases:
  - name: webapp
    chart: ./charts/webapp-template
    namespace: default
    values:
      - ../clusters/dev/values-local.yaml
```