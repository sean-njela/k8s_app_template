# .github/workflows/ – GitHub Actions CI / CD pipelines

Three opinionated workflows:

- `build.yml` → unit‑test, build, scan, push image to registry.
- `deploy.yml` → after image push, auto‑PR to GitOps branch (clusters/*) so Argo CD rolls out.
- `infra.yml` → Terraform plan/apply for infra/envs/* (with required review in prod).

These are ready‑to‑commit; fill in secrets under Settings ➜ Secrets and variables ➜ Actions.

---

```
.github/
└── workflows/
    ├── build.yml
    ├── deploy.yml
    └── infra.yml
```
--- 

## build.yml – Continuous Integration & Image Publish

### What it does

- Checks out code and runs language‑specific tests.
- Builds a multi‑arch image with Buildx and pushes on main commits.
- Runs Trivy CVE scan — fails build on High/Critical findings.
- Saves the image‑tag for downstream workflows.

--- 

## deploy.yml – GitOps Promotion to Staging ➜ Prod

### Flow
CI success triggers Deploy. 
A bot branch edits the Helmfile values to point to the new image tag, opens a PR. 
Merging → Argo CD syncs clusters. 

---

## infra.yml – Terraform Plan / Apply

The `workflow_dispatch` input lets you trigger runs ad‑hoc. Set branch protections so prod applies require approval.

### Required Secrets / Vars

| Name            | Used by            | Notes
|-----------------|---------------------|-----------------
| GCP_PROJECT_ID  | infra   | Your GCP project ID
| GCP_WIF_PROVIDER| infra   | Workload Identity Federation pool provider name
| GCP_TF_SA       | infra   | Service account email with roles/editor, roles/container.admin etc.
| GHCR_TOKEN / default GITHUB_TOKEN | build | Registry auth

### Next
Add any language‑specific test steps you wish.

---

### Note
> The Context access might be invalid warning will appear in your editor. This is expected because your local environment doesn't have access to your GitHub secrets. The workflow will run correctly on GitHub.
