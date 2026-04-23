# Sealed Secrets Workflow

This folder contains a script and templates to generate SealedSecret YAMLs.

## Directory layout

- `certs/` -> place the Sealed Secrets public cert here
- `input/` -> actual secrets (.env) used for sealing (gitignored)
- `input-templates/` -> safe templates you can commit
- `generate-sealed-secrets.sh` -> creates SealedSecret YAMLs
- Output -> written to `ustbite-helm-charts/infra/secrets/<dev|prod>/...`

## Steps (cluster machine or any machine with kubectl + kubeseal)

1) Install Sealed Secrets controller (one time):

```bash
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.27.0/controller.yaml
```

2) Fetch the public cert and save it:

```bash
kubeseal --fetch-cert \
  --controller-namespace=kube-system \
  --controller-name=sealed-secrets-controller \
  > sealed-secrets/certs/sealed-secrets-public.pem
```

3) Copy templates into `input/` and fill real values:

```bash
mkdir -p sealed-secrets/input/dev sealed-secrets/input/prod
cp sealed-secrets/input-templates/dev/*.env sealed-secrets/input/dev/
cp sealed-secrets/input-templates/prod/*.env sealed-secrets/input/prod/
# Edit each .env file with real secrets
```

4) Generate SealedSecrets:

```bash
bash sealed-secrets/generate-sealed-secrets.sh dev
bash sealed-secrets/generate-sealed-secrets.sh prod
```

5) Commit ONLY the output under `infra/secrets/`:

```bash
git add infra/secrets
git commit -m "feat: add sealed secrets"
git push origin develop
git push origin main
```

Notes:
- The `input/` directory is gitignored on purpose.
- The output is GitOps-managed by the ArgoCD infra Application.
