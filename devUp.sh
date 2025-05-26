#!/bin/bash

# ============================================
# devUp.sh
# ============================================
# Description:
#   Orchestrates full local dev environment:
#   - Starts Minikube
#   - Builds JARs
#   - Builds Docker images for Minikube
#   - Installs Helm charts
# ============================================

set -e  # Exit on any error

# Step 1: Start Minikube with specific resources
echo "🚀 Starting Minikube with 10GB RAM and 3 CPUs..."
minikube start --memory=10240 --cpus=3

# Step 2: Build all microservice JARs
echo "🛠️ Building JARs..."
bash ./build/buildJar.sh

# Step 3: Build Docker images targeting Minikube
echo "🐳 Building Docker images for Minikube..."
bash ./build/buildImagesForMinikube.sh

# Step 4: Install Helm charts
echo "📦 Installing Helm charts..."
bash ./helm/installCharts.sh

echo "🎉 Development environment is ready!"
