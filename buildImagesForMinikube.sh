#!/bin/bash

# ============================================
# build-images.sh
# ============================================
# Description:
#   Builds Docker images using version from pom.xml as --build-arg.
#   Works with Dockerfiles using ARG PROJECT_VERSION.
#   Targets Minikube Docker daemon.
#   Builds specific services if passed as arguments, otherwise defaults to all.
# ============================================

# Resolve script directory and base services folder
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Default list of microservices
DEFAULT_SERVICES=(
  "service-discovery"
  "cloud-config"
  "proxy-client"
  "api-gateway"
  "user-service"
)

# If arguments are provided, use them as services to build; otherwise use default
if [[ $# -gt 0 ]]; then
  SERVICES=("$@")
else
  SERVICES=("${DEFAULT_SERVICES[@]}")
fi

# Use Minikube Docker daemon
echo "📡 Switching Docker environment to Minikube..."
eval "$(minikube docker-env)"

# Loop through services
for SERVICE in "${SERVICES[@]}"; do
  SERVICE_PATH="$BASE_DIR/$SERVICE"

  echo "🔍 Building: $SERVICE"
  echo " Service path: $SERVICE_PATH"

  # Check required files
  if [[ ! -f "$SERVICE_PATH/mvnw" || ! -f "$SERVICE_PATH/Dockerfile" ]]; then
    echo "❌ Missing mvnw or Dockerfile in $SERVICE — skipping"
    continue
  fi

  # Extract version from pom.xml
  pushd "$SERVICE_PATH" > /dev/null
  PROJECT_VERSION=$(./mvnw help:evaluate -Dexpression=project.version -q -DforceStdout)
  popd > /dev/null

  if [[ -z "$PROJECT_VERSION" ]]; then
    echo "❌ Failed to extract version from $SERVICE"
    continue
  fi

  echo "📦 Version: $PROJECT_VERSION"

  # Build Docker image using --build-arg
  docker build --build-arg PROJECT_VERSION="$PROJECT_VERSION" -t "$SERVICE:dev" "$SERVICE_PATH"

  if [[ $? -ne 0 ]]; then
    echo "❌ Build failed for $SERVICE"
    exit 1
  fi

  echo "✅ Built $SERVICE:$PROJECT_VERSION"
  echo "-------------------------------------------"
done

# Show built images
echo "📦 Images built in Minikube:"
docker images | grep -E "$(IFS=\|; echo "${SERVICES[*]}")"

echo "🎉 Done building selected service images!"
