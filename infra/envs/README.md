# infra/ – Terraform IaC for GKE Autopilot

This folder contains fully‑repeatable, minimal‑overhead Terraform configurations for two Google Cloud environments (staging and prod). Each environment is an independent Terraform root module that can be applied in isolation. Only modules published under terraform-google-modules are used.

## Prerequisites

- Terraform ≥ 1.8
- gcloud with Application‑Default Credentials (ADC) configured
- A versioned GCS bucket for remote state (create once—outside of Terraform—to avoid chicken‑and‑egg problems).

## Structure

```
infra/
└── envs/
    ├── staging/
    │   ├── backend.tf       # Remote state → GCS (prefix = "staging")
    │   ├── versions.tf      # Terraform + provider requirements
    │   ├── variables.tf     # Input variables (project_id, region …)
    │   ├── main.tf          # GKE Autopilot + supporting modules
    │   └── outputs.tf       # Handy outputs (cluster endpoint, name …)
    └── prod/
        ├── backend.tf       # Remote state → GCS (prefix = "prod")
        ├── versions.tf
        ├── variables.tf
        ├── main.tf
        └── outputs.tf
```

Prod environment (envs/prod/) is 100% identical except for:
• backend.tf prefix → gke/prod
• locals.environment → prod
• Secondary CIDRs shifted to avoid overlap.

All prod files are provided below for copy-paste parity.

## How to apply

```bash
cd infra/envs/staging    # or prod

# One-time: write backend bucket + prefix in backend.tf,
# then initialise remote state (first run only)
terraform init

# Plan the changes
terraform plan \
  -var="project_id=my-solo-dev-123" \
  -var="region=europe-central2"

# Apply if the plan looks good
terraform apply -auto-approve

# ⏱️~15 minutes later: use gcloud to fetch kubeconfig
 gcloud container clusters get-credentials staging-autopilot \
   --region europe-central2 --project my-solo-dev-123