#!/usr/bin/env bash
# Deploy observability-carbon stack on the current kube-context.
# Usage: ./scripts/deploy.sh [region] [intensity]
#   region    : free-form region label (default CH)
#   intensity : carbon intensity in gCO2eq/kWh (default 128)
set -euo pipefail

REGION="${1:-CH}"
INTENSITY="${2:-128}"
NAMESPACE="${NAMESPACE:-observability}"
RELEASE="${RELEASE:-obs-carbon}"
CHART_DIR="$(cd "$(dirname "$0")/.." && pwd)/charts/observability-carbon"

echo "Deploying observability-carbon"
echo "  region    : ${REGION}"
echo "  intensity : ${INTENSITY} gCO2eq/kWh"
echo "  namespace : ${NAMESPACE}"
echo "  release   : ${RELEASE}"

helm dependency update "${CHART_DIR}"

helm upgrade --install "${RELEASE}" "${CHART_DIR}" \
  --namespace "${NAMESPACE}" --create-namespace \
  --set "carbon.region=${REGION}" \
  --set "carbon.intensityGramsPerKwh=${INTENSITY}" \
  --wait --timeout 10m

echo
echo "Done. Port-forward Grafana with:"
echo "  kubectl -n ${NAMESPACE} port-forward svc/${RELEASE}-grafana 3000:80"
echo "Then open http://localhost:3000 (admin / prom-operator)."
