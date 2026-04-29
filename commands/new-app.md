---
description: Scaffold a new app following the local kind cluster conventions (namespace, deployment, service, justfile, registry wiring).
---

You are scaffolding a new Kubernetes app for a local kind cluster. The app name is: `$ARGUMENTS`

If no app name was provided, ask for one before continuing.

---

## Step 1 — Gather requirements

Ask the user these questions **all at once** (don't ask one at a time):

1. **Port** — What port does the app container expose? (e.g. `8080`)
2. **Secrets** — Does this app need a `.env` file / Kubernetes Secret? (yes/no)
3. **Custom image** — Does this app have its own `Dockerfile` to build and push, or does it use an upstream image directly? (custom / upstream)
   - If upstream: what is the image reference? (e.g. `ghcr.io/foo/bar:latest`)
4. **Persistent storage** — Does it need a PVC? (yes/no)
   - If yes: how much storage? (e.g. `5Gi`)
5. **VPN routing** — Does this app need to route traffic through the nordlynx SOCKS5 proxy? (yes/no)

Wait for all answers before writing any files.

---

## Step 2 — Confirm the plan

Print a short summary of what you're about to create, e.g.:

```
App:       my-app
Directory: ~/development/my-app/
Image:     localhost:5001/my-app:dev  (custom Dockerfile)
Port:      8080
Secrets:   yes  →  my-app-env
PVC:       yes  →  my-app-data (5Gi)
VPN:       no
Files:
  ~/development/my-app/k8s/namespace.yaml
  ~/development/my-app/k8s/deployment.yaml
  ~/development/my-app/k8s/service.yaml
  ~/development/my-app/k8s/pvc.yaml          (if PVC)
  ~/development/my-app/.env.example           (if secrets)
  ~/development/my-app/Dockerfile             (if custom image)
  ~/development/my-app/justfile
  ~/development/kubernetes/apps/my-app.yaml
  ~/development/kubernetes/justfile           (deploy-apps updated)
```

Ask the user to confirm before writing anything.

---

## Step 3 — Write the files

Use the exact conventions below. Replace `<APP>` with the app name throughout.

### `~/development/<APP>/k8s/namespace.yaml`
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: <APP>
```

### `~/development/<APP>/k8s/deployment.yaml`

Use `imagePullPolicy: Always` (never `Never`).

If **custom image**: `image: localhost:5001/<APP>:dev`
If **upstream image**: use the image reference the user provided.

If **secrets**: mount the secret as env vars:
```yaml
      envFrom:
        - secretRef:
            name: <APP>-env
```

If **VPN routing**: add this env var to the container:
```yaml
          env:
            - name: SOCKS5_PROXY_URL
              value: "socks5://nordlynx.nordlynx.svc.cluster.local:1080"
```

If **PVC**: add a volumeMount and volume referencing `<APP>-data`.

Full template:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: <APP>
  namespace: <APP>
spec:
  replicas: 1
  selector:
    matchLabels:
      app: <APP>
  template:
    metadata:
      labels:
        app: <APP>
    spec:
      containers:
        - name: <APP>
          image: <IMAGE>
          imagePullPolicy: Always
          ports:
            - containerPort: <PORT>
              name: web
          # envFrom / env / volumeMounts go here based on answers
      # volumes go here based on answers
```

### `~/development/<APP>/k8s/service.yaml`

Always `ClusterIP` — never `NodePort` or `LoadBalancer`.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: <APP>
  namespace: <APP>
spec:
  selector:
    app: <APP>
  ports:
    - name: web
      port: <PORT>
      targetPort: <PORT>
```

### `~/development/<APP>/k8s/pvc.yaml` (only if PVC requested)

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: <APP>-data
  namespace: <APP>
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: <SIZE>
```

### `~/development/<APP>/.env.example` (only if secrets requested)

```
# Copy to .env and fill in values
# EXAMPLE_VAR=value
```

### `~/development/<APP>/Dockerfile` (only if custom image)

Write a minimal skeleton appropriate for the app. If you can infer the language/runtime from the app name, tailor it. Otherwise use a generic multi-stage pattern:

```dockerfile
FROM <base-image> AS build
WORKDIR /app
COPY . .
# RUN build command here

FROM <runtime-image>
WORKDIR /app
COPY --from=build /app/<artifact> .
EXPOSE <PORT>
CMD ["<entrypoint>"]
```

### `~/development/<APP>/justfile`

If **custom image**, include `build`/`push` steps in `deploy`. If **upstream image**, skip docker build/push.
If **secrets**, include a `secret` recipe. Never create a `secret.yaml` file.

```just
# <APP> — local dev recipes
# Usage: just <recipe>
# Run from ~/development/<APP>/

cluster       := env("CLUSTER", "kind")
registry_port := env("REGISTRY_PORT", "5001")
namespace     := "<APP>"

default:
    @just --list

# Build, push, and apply manifests
deploy:
    #!/usr/bin/env bash
    set -euo pipefail
    if ! docker ps --filter "name=kind-registry" --format "{{{{.Names}}" | grep -q "kind-registry"; then
        echo "✗ Local registry is not running. Run 'just start' from the kubernetes directory." >&2; exit 1
    fi
    # (if custom image)
    echo "=> Building <APP> image..."
    docker build -t localhost:{{registry_port}}/<APP>:dev .
    echo "=> Pushing to local registry..."
    docker push localhost:{{registry_port}}/<APP>:dev
    echo "=> Applying manifests..."
    kubectl apply -f k8s/ --context "kind-{{cluster}}"
    echo "✓ <APP> deployed."

# (if secrets) Create/update the Secret from .env
secret:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -f ".env" ]; then
        echo "✗ .env not found. Copy .env.example and fill in your values." >&2; exit 1
    fi
    kubectl create namespace "{{namespace}}" --context "kind-{{cluster}}" 2>/dev/null || true
    kubectl create secret generic <APP>-env \
        -n "{{namespace}}" \
        --context "kind-{{cluster}}" \
        --from-env-file=.env \
        --dry-run=client -o yaml | kubectl apply -f -
    echo "✓ <APP> secret created/updated."

restart:
    kubectl rollout restart deployment/<APP> \
        -n "{{namespace}}" --context "kind-{{cluster}}"
    kubectl rollout status deployment/<APP> \
        -n "{{namespace}}" --context "kind-{{cluster}}"
    echo "✓ <APP> restarted."

logs:
    kubectl logs -n "{{namespace}}" --context "kind-{{cluster}}" \
        --all-containers --prefix --follow \
        -l app=<APP>

forward:
    #!/usr/bin/env bash
    set -euo pipefail
    POD=$(kubectl get pod -n "{{namespace}}" --context "kind-{{cluster}}" \
        -l app=<APP> -o jsonpath='{.items[0].metadata.name}')
    if [ -z "$POD" ]; then
        echo "✗ No running <APP> pod found." >&2; exit 1
    fi
    kubectl port-forward -n "{{namespace}}" --context "kind-{{cluster}}" \
        "pod/$POD" <PORT>:<PORT> >/tmp/<APP>-forward.log 2>&1 &
    echo $! > /tmp/<APP>-forward.pid
    echo "✓ Port-forward running (PID $(cat /tmp/<APP>-forward.pid))"
    echo "  Open: http://localhost:<PORT>"
    echo "  Stop: just forward-stop"

forward-stop:
    #!/usr/bin/env bash
    if [ ! -f /tmp/<APP>-forward.pid ]; then
        echo "No PID file found." >&2; exit 1
    fi
    kill "$(cat /tmp/<APP>-forward.pid)" 2>/dev/null \
        && echo "✓ Port-forward stopped." \
        || echo "Process already stopped."
    rm /tmp/<APP>-forward.pid

teardown:
    kubectl delete -f k8s/ --context "kind-{{cluster}}" --ignore-not-found
    echo "✓ <APP> removed from cluster."
```

### `~/development/kubernetes/apps/<APP>.yaml`

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: <APP>
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/tostinat/<APP>
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: <APP>
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

## Step 4 — Update `~/development/kubernetes/justfile`

Read the current `deploy-apps` recipe. Add `<APP>` to:
1. The namespace loop (the `for app in ...` line that runs `kubectl apply -f namespace.yaml`)
2. The correct deployment group:
   - **With secrets**: the loop that runs `just secret && just deploy`
   - **Without secrets**: the loop that runs `just deploy`

Do a minimal edit — only touch the two lines that list app names. Do not restructure the recipe.

---

## Step 5 — Print next steps

```
✓ <APP> scaffolded.

Next steps:
  cd ~/development/<APP>
  cp .env.example .env && vim .env    # (if secrets)
  # write your Dockerfile / code
  just secret                          # (if secrets)
  just deploy

To include in a full cluster redeploy:
  cd ~/development/kubernetes && just deploy-apps
```

If the app has secrets, remind the user: never commit `.env` — it's in `.gitignore` by convention.
