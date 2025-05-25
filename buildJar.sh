#!/bin/bash

# ============================================
# build-all.sh
# ============================================
# Description:
#   Runs `./mvnw clean package` for each service
#   passed as argument or listed in DEFAULT_SERVICES.
#
# Usage:
#   chmod +x build-all.sh
#   ./build-all.sh           # builds default services
#   ./build-all.sh user-service api-gateway  # builds only specified
# ============================================

# Resolve script and base directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Default list of services
DEFAULT_SERVICES=(
  "api-gateway"
  "cloud-config"
  "proxy-client"
  "service-discovery"
  "user-service"
)

# Use provided args as service list or fallback to default
if [[ $# -gt 0 ]]; then
  SERVICES=("$@")
else
  SERVICES=("${DEFAULT_SERVICES[@]}")
fi

echo "🔨 Starting build process from: $BASE_DIR"
echo "-------------------------------------------"

for SERVICE in "${SERVICES[@]}"; do
  SERVICE_PATH="$BASE_DIR/$SERVICE"

  echo "👉 Entering: $SERVICE_PATH"

  if [ -f "$SERVICE_PATH/mvnw" ]; then
    cd "$SERVICE_PATH" || { echo "❌ Failed to enter $SERVICE_PATH"; exit 1; }
    echo "🚀 Building $SERVICE ..."
    ./mvnw clean package
    echo "✅ Finished building $SERVICE"
  else
    echo "⚠️ Skipping $SERVICE - mvnw not found in $SERVICE_PATH"
  fi

  echo "-------------------------------------------"
done

echo "🏁 Build process completed for selected services."
