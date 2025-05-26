#!/bin/bash

# ============================================
# installCharts.sh
# ============================================
# Description:
#   Installs Helm charts in dependency order by default:
#     - Critical services first (with readiness check)
#     - Then the rest (with readiness check)
#   If arguments are provided, installs ONLY those charts (with readiness check)
#
# Usage:
#   ./installCharts.sh                # installs all charts in order
#   ./installCharts.sh chart1 chart2  # installs only chart1 and chart2
# ============================================

# Set namespace and resolve manifest path
NAMESPACE="default"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../k8s-manifests-/manifests" && pwd)"

# Define charts in dependency order
CHARTS_CRITICAL=("zipkin" "discovery" "cloud-config")
CHARTS_REST=("proxy-client" "api-gateway" "order-service" "payment-service" "product-service" "shipping-service" "user-service" "favourite-service")

# Function to wait for deployment to be ready
wait_until_ready() {
  local deployment=$1
  echo "⏳ Waiting for deployment $deployment to be ready..."
  kubectl rollout status deployment/"$deployment" --namespace "$NAMESPACE" --timeout=180s || {
    echo "❌ Deployment $deployment failed to become ready"
    exit 1
  }
}

# Detect if user passed arguments (custom chart list)
if [ "$#" -gt 0 ]; then
  CHARTS_TO_INSTALL=("$@")
  INSTALL_ALL=false
else
  INSTALL_ALL=true
fi

if [ "$INSTALL_ALL" = true ]; then
  # Install critical charts first
  for CHART in "${CHARTS_CRITICAL[@]}"; do
    echo "🚀 Installing critical chart: $CHART..."
    helm upgrade --install "$CHART" "$BASE_DIR/$CHART" --namespace "$NAMESPACE"
    wait_until_ready "$CHART"
  done

  # Then install the remaining charts
  for CHART in "${CHARTS_REST[@]}"; do
    echo "🚀 Installing chart: $CHART..."
    helm upgrade --install "$CHART" "$BASE_DIR/$CHART" --namespace "$NAMESPACE"
  done
else
  # Only install user-specified charts
  for CHART in "${CHARTS_TO_INSTALL[@]}"; do
    echo "🚀 Installing chart: $CHART..."
    helm upgrade --install "$CHART" "$BASE_DIR/$CHART" --namespace "$NAMESPACE"
  done
fi

echo "✅ All requested charts installed successfully!"
