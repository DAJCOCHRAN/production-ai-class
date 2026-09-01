# Module 5 - GPU Workloads on AKS

## Overview

In this module you will deploy a GPU-enabled AKS cluster, publish your application images to ACR, configure GPU time-slicing resources, and deploy the full stack using Helm.

## Prerequisites

- Azure CLI installed and authenticated (`az login`)
- Docker installed
- kubectl installed
- Helm CLI installed
- An Azure Container Registry (ACR) already provisioned
- Watched the AKS infrastructure deployment from the module video

## Step 1: Deploy AKS Infrastructure

Follow the instructions in the **Module 5 video** to deploy your AKS cluster with GPU node pools using the Azure CLI or the provided IaC templates.

Once the cluster is deployed, connect to it:

```bash
az aks get-credentials --resource-group <RESOURCE_GROUP> --name <AKS_CLUSTER_NAME>
```

Verify connectivity:

```bash
kubectl get nodes
```

You should see your nodes, including any GPU-enabled node pools.

## Step 2: Build and Push Images to ACR

Log in to your ACR:

```bash
az acr login --name <ACR_NAME>
```

### Build and push the gpu-app image

```bash
cd 705.604/module05/gpu-app
docker build -t <ACR_DOMAIN_NAME>/gpu-app:<TAG> .
docker push <ACR_DOMAIN_NAME>/gpu-app:<TAG>
```

### Build and push the gateway-service image

```bash
cd 705.604/module05/gateway-service
docker build -t <ACR_DOMAIN_NAME>/gateway-service:<TAG> .
docker push <ACR_DOMAIN_NAME>/gateway-service:<TAG>
```

Replace `<ACR_DOMAIN_NAME>` with your ACR login server (e.g. `myacr.azurecr.io`) and `<TAG>` with your desired image tag (e.g. `v1`).

## Step 3: Deploy GPU Kubernetes Resources

These resources configure GPU time-slicing and the NVIDIA device plugin on your cluster.

Navigate to the gpu-kube-resources directory:

```bash
cd 705.604/module05/gpu-kube-resources
```

### Deploy the ConfigMap (required for the device plugin)

```bash
kubectl apply -f gpu-time-slicing-config.yaml
```

Verify it was created:

```bash
kubectl get configmap device-plugin-config -n kube-system
```

### Deploy the GPU device plugin DaemonSet

```bash
kubectl apply -f gpu-operator-daemonset.yaml
```

### Wait for the DaemonSet to be ready

```bash
kubectl wait --for=condition=ready pod \
  -l name=nvidia-device-plugin-ds \
  -n kube-system \
  --timeout=300s
```

## Step 4: Deploy with Helm

Before deploying, update `helm-chart/values.yaml` with your ACR domain name and image tags:

```yaml
acr: <ACR_DOMAIN_NAME>

gateway:
  image: gateway-service
  tag: <GATEWAY_SERVICE_TAG>
  port: 5000

myGPUApp:
  image: gpu-app
  tag: <GPU_APP_TAG>
  replicas: 1
  port: 8000
```

### Install the Helm chart

```bash
cd 705.604/module05/helm-chart
helm install mychart .
```

### Verify the deployment

```bash
kubectl get pods
kubectl get services
```

### Useful Helm commands

Upgrade after making changes:

```bash
helm upgrade mychart .
```

Uninstall:

```bash
helm uninstall mychart
```