# 📦 DEVELOPMENT-SCRIPTS


Must hava this folder structure:

├── cloud-config-server
├── ecommerce-parent
├── k8s-manifests-
└── services
    ├── api-gateway
    ├── cloud-config
    ├── development-scripts
    ├── favourite-service
    ├── order-service
    ├── payment-service
    ├── product-service
    ├── proxy-client
    ├── service-discovery
    ├── shipping-service
    └── user-service


This directory contains helper scripts used to build, deploy, and manage the local development environment based on **Minikube** and **Helm** for the ecommerce microservices project.

---

### 🗂️ Folder Structure

```bash
DEVELOPMENT-SCRIPTS/
├── build/
│   ├── buildImagesForMinikube.sh   # Builds Docker images for Minikube
│   └── buildJar.sh                 # Builds JAR files using Maven
├── helm/
│   ├── installCharts.sh           # Installs Helm charts in order
│   └── uninstallCharts.sh         # Uninstalls Helm charts
├── devUp.sh                        # Main orchestrator script
└── README.md                       # You're here!
```

---

### 🚀 Main Workflow

#### `devUp.sh`

> **Runs the full local development pipeline**

```bash
./devUp.sh
```

What it does:

1. Starts Minikube with `10GB RAM` and `3 CPUs`.
2. Builds all microservice JARs (`./build/buildJar.sh`).
3. Builds Docker images inside Minikube Docker daemon (`./build/buildImagesForMinikube.sh`).
4. Installs Helm charts in the correct dependency order (`./helm/installCharts.sh`).

---

### ⚙️ Build Scripts

#### `buildJar.sh`

> Compiles all microservices using their local Maven wrapper (`./mvnw clean package`).

Usage:

```bash
./build/buildJar.sh
```

📍 Automatically locates all services and builds them in sequence.

---

#### `buildImagesForMinikube.sh`

> Builds Docker images for each microservice inside the Minikube Docker environment.

Usage:

```bash
./build/buildImagesForMinikube.sh [optional-service-name...]
```

📝 If no service is specified, it builds all services listed in the script.
✅ If one or more services are passed as arguments, it builds only those.

Example:

```bash
./build/buildImagesForMinikube.sh user-service api-gateway
```

---

### 📦 Helm Charts

#### `installCharts.sh`

> Installs Helm charts in a defined order (ensuring `zipkin`, `discovery`, `cloud-config` are ready before the rest).

Usage:

```bash
./helm/installCharts.sh [optional-service-name...]
```

* If services are passed as arguments → only those are installed.
* If no arguments → full dependency-aware deployment.

🎯 Includes readiness checks using `kubectl rollout status`.

---

#### `uninstallCharts.sh`

> Deletes all Helm releases from the Kubernetes cluster (Minikube).

Usage:

```bash
./helm/uninstallCharts.sh
```

---

### 💡 Notes

* These scripts are tailored for **development** use only.
* Ensure `minikube` and `helm` are installed and configured on your machine.
* Docker builds are targeted directly into Minikube via `eval "$(minikube docker-env)"`.

---

### 👨‍💻 Dev Tips

* You can run any script individually, but `devUp.sh` is the fastest way to spin up a fully working environment.
* Use `uninstallCharts.sh` if you want to reset the cluster without restarting Minikube.

