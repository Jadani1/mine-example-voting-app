# Helm chart: Example Voting App

Deploys **vote**, **result**, **worker**, **redis**, and **postgres** using the same service names and NodePorts as `k8s-specifications/`.

| Service | Default type | Port / NodePort |
|---------|--------------|-----------------|
| vote    | NodePort     | 8080 → 80 / **31000** |
| result  | NodePort     | 8081 → 80 / **31001** |
| redis   | ClusterIP    | 6379 |
| db      | ClusterIP    | 5432 |
| worker  | (no Service) | — |

---

## Prerequisites

- Kubernetes cluster (Kind, Minikube, or cloud)
- [Helm 3](https://helm.sh/docs/intro/install/)
- `kubectl` pointed at the cluster

```bash
kubectl cluster-info
helm version
```

---

## Step 1 — Deploy the good release (v1)

From the **repo root**:

```bash
helm install voting-app ./helm/voting-app -f ./helm/voting-app/values.yaml
```

Optional: use images you pushed from CI (replace `YOURUSER`):

```bash
helm install voting-app ./helm/voting-app \
  -f ./helm/voting-app/values.yaml \
  --set imageRegistry=YOURUSER \
  --set vote.image.repository=vote \
  --set result.image.repository=result \
  --set worker.image.repository=worker \
  --set vote.image.tag=latest \
  --set result.image.tag=latest \
  --set worker.image.tag=latest
```

Verify:

```bash
helm status voting-app
helm history voting-app
kubectl get pods,svc
```

Revision **1** should show as **deployed**. Pods should become `Running` / `Ready`.

UI (Kind/Minikube node IP or port-forward):

```bash
# Kind: map NodePorts, or:
kubectl port-forward svc/vote 8080:8080
kubectl port-forward svc/result 8081:8081
# Vote: http://localhost:8080   Results: http://localhost:8081
```

---

## Step 2 — Ship a bad release on purpose

`values-bad.yaml` sets **non-existent image tags** so app pods fail with `ErrImagePull` / `ImagePullBackOff`.

```bash
helm upgrade voting-app ./helm/voting-app \
  -f ./helm/voting-app/values.yaml \
  -f ./helm/voting-app/values-bad.yaml
```

Or without the bad file:

```bash
helm upgrade voting-app ./helm/voting-app \
  -f ./helm/voting-app/values.yaml \
  --set vote.image.tag=nonexistent-tag-999 \
  --set result.image.tag=nonexistent-tag-999 \
  --set worker.image.tag=nonexistent-tag-999
```

Verify failure:

```bash
helm status voting-app
kubectl get pods
kubectl describe pod -l app=vote | tail -20
helm history voting-app
```

You should see pull errors and a new revision (e.g. **2**) for the broken upgrade.

---

## Step 3 — Roll back with `helm rollback`

Restore the previous stable revision (**1**):

```bash
helm rollback voting-app 1
```

Or roll back one step (omit revision):

```bash
helm rollback voting-app
```

Verify recovery:

```bash
helm status voting-app
helm history voting-app
kubectl get pods
```

Helm creates a **new** revision (e.g. **3**) that re-applies the config from revision 1. App pods should pull valid images and run again.

---

## Useful commands

```bash
# Render manifests without installing
helm template voting-app ./helm/voting-app -f ./helm/voting-app/values.yaml

# Lint the chart
helm lint ./helm/voting-app

# Diff (requires helm-diff plugin)
helm diff upgrade voting-app ./helm/voting-app -f ./helm/voting-app/values.yaml

# Uninstall
helm uninstall voting-app
```

Limit retained revisions (avoids clutter):

```bash
helm upgrade voting-app ./helm/voting-app -f ./helm/voting-app/values.yaml --history-max 10
```

---

## Values overview

| Key | Purpose |
|-----|---------|
| `imageRegistry` | Optional prefix (e.g. Docker Hub username) for vote/result/worker |
| `vote|result|worker.image.*` | App image repository, tag, pullPolicy |
| `vote|result.replicaCount` | Replicas |
| `vote|result.service.*` | Service type, ports, nodePort |
| `db.env.*` | Postgres credentials (also wired into result/worker) |
| `*.enabled` | Toggle individual components |

Bad-release overlay: `values-bad.yaml` (image tags only).

---

## Best practices for rollbacks

1. **Keep history bounded** — `--history-max` on install/upgrade.
2. **CI health checks** — after `helm upgrade`, run smoke tests (`kubectl rollout status`, HTTP probes); on failure, `helm rollback <release>`.
3. **Prefer immutable tags** — avoid `latest` in production; pin SHA or semver tags from CI.
4. **Don’t rely on emptyDir for prod data** — chart uses `emptyDir` for db/redis to match the sample specs; use PVCs for real environments.
5. **Secrets** — demo passwords live in values; move to Sealed Secrets / External Secrets / SOPS for anything shared.

---

## Relation to plain manifests

Equivalent baseline lives in `k8s-specifications/`. This chart parameterizes the same layout so you can upgrade and **rollback** with Helm instead of re-applying static YAML.
