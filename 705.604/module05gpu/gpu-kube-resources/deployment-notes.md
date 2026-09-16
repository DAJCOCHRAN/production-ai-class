# GPU Device Plugin Deployment Notes

## Prerequisites
You must be logged into the AKS cluster, check the login instructions from AKS in azure portal or check the video


Navigate to the gpu-kube-resources directory:

```bash
cd 705.604/module05gpu/gpu-kube-resources
```

## Steps

### 1. Deploy the ConfigMap (required for device plugin)

```bash
kubectl apply -f gpu-time-slicing-config.yaml
```

Verify it was created:

```bash
kubectl get configmap device-plugin-config -n kube-system
```

### 2. Deploy the GPU device plugin DaemonSet

```bash
kubectl apply -f gpu-operator-daemonset.yaml
```

### 3. Wait for the DaemonSet to be ready

```bash
kubectl wait --for=condition=ready pod \
  -l name=nvidia-device-plugin-ds \
  -n kube-system \
  --timeout=300s
```
