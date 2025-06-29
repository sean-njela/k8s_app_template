# dev/ – Local‑only Developer Experience (Tilt + Values)

Work fast against a single‑node K3s cluster—no cloud required.  The Tiltfile hot‑reloads code and values‑local.yaml tweaks the Helm chart for desktop‑friendly settings.

```
dev/
├── Tiltfile            # Live‑update & deploy to K3s
└── values-local.yaml   # Helm overrides for local runs
```
---
## Tiltfile

### What it does

- docker_build – builds the image locally + live‑updates source code.
- helm template – renders chart with values‑local.yaml and image tag dev.
- k8s_resource – port‑forward container port 8080 to localhost:8080.

> Adjust the build commands (npm, go, etc.) to match your tech stack.

---
## Usage cheat‑sheet

```bash
# 0. Ensure k3s/k3d cluster exists and KUBECONFIG points to it
kubectl config use-context k3s-dev

# 1. Start Tilt dashboard (opens in browser)
 tilt up

# 2. Code ➜ save ➜ hot‑reloads in ~1 sec

# 3. Hit the app at http://localhost:8080 or specify port in values-local.yaml
```
