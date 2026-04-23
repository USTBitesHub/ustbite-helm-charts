#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERT="${ROOT_DIR}/certs/sealed-secrets-public.pem"
INPUT_DIR="${ROOT_DIR}/input"
OUTPUT_DIR="${ROOT_DIR}/../infra/secrets"

usage() {
  echo "Usage: $0 <dev|prod>" 1>&2
  exit 1
}

ENVIRONMENT="${1:-}"
if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "prod" ]]; then
  usage
fi

if ! command -v kubectl >/dev/null 2>&1; then
  echo "ERROR: kubectl not found in PATH" 1>&2
  exit 1
fi

if ! command -v kubeseal >/dev/null 2>&1; then
  echo "ERROR: kubeseal not found in PATH" 1>&2
  exit 1
fi

if [[ ! -f "$CERT" ]]; then
  echo "ERROR: missing public cert at: $CERT" 1>&2
  exit 1
fi

services=(
  "user-service"
  "restaurant-service"
  "order-service"
  "payment-service"
  "delivery-service"
  "notification-service"
  "metrics-collector"
  "log-aggregator"
  "ai-agent-service"
)

declare -A namespaces
namespaces["user-service"]="ustbite-backend"
namespaces["restaurant-service"]="ustbite-backend"
namespaces["order-service"]="ustbite-backend"
namespaces["payment-service"]="ustbite-backend"
namespaces["delivery-service"]="ustbite-backend"
namespaces["notification-service"]="ustbite-backend"
namespaces["metrics-collector"]="ustbite-ops"
namespaces["log-aggregator"]="ustbite-ops"
namespaces["ai-agent-service"]="ustbite-ops"

mkdir -p "$OUTPUT_DIR/$ENVIRONMENT"

for service in "${services[@]}"; do
  ns="${namespaces[$service]}"
  env_file="$INPUT_DIR/$ENVIRONMENT/$service.env"

  if [[ ! -f "$env_file" ]]; then
    echo "ERROR: missing env file: $env_file" 1>&2
    exit 1
  fi

  secret_name="ustbite-${service}-${ENVIRONMENT}-secret"
  out_dir="$OUTPUT_DIR/$ENVIRONMENT/$ns"
  out_file="$out_dir/${service}-sealed-secret.yaml"

  mkdir -p "$out_dir"

  kubectl create secret generic "$secret_name" \
    -n "$ns" \
    --from-env-file "$env_file" \
    --dry-run=client -o yaml \
  | kubeseal \
      --cert "$CERT" \
      --format yaml \
      --namespace "$ns" \
  > "$out_file"

  echo "Wrote: $out_file"
done

echo "Done. Commit files under: $OUTPUT_DIR/$ENVIRONMENT"
