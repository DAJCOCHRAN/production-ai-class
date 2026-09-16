# JHU Production AI - Module 05: Message Fan-Out on AKS

In this module you deploy a CPU Azure Kubernetes Service (AKS) cluster with Terraform and run
a small message fan-out system on it with Helm. A gateway receives one message, finds every
worker pod through a headless Service, and sends the message to all of them at once. Each
worker answers with the name of the pod and the node it runs on, so the response shows the
message crossing pods and nodes.

The cluster is CPU only. Nothing in this module needs a GPU.

## Architecture Overview

```
                 POST /fanout {"message": "..."}
   client  ─────────────────────────────────────►  gateway  (LoadBalancer, port 80)
                                                      │
                                                      │  DNS lookup of "worker-app"
                                                      │  (headless Service: one address per pod)
                                                      ▼
                          ┌───────────────────────────┼───────────────────────────┐
                          ▼                           ▼                           ▼
                    worker-app pod              worker-app pod              worker-app pod
                    node 1                      node 2                      node 1
                    POST /process               POST /process               POST /process
                          │                           │                           │
                          └───────────── {pod, node, message, received_at} ───────┘
                                                      │
                                                      ▼
                       {"message": ..., "worker_count": 3, "responses": [ ... ]}
```

| Component | Folder | What it does |
|---|---|---|
| `worker-app` | `worker-app/` | Flask on port 8000. `GET /status` returns `{pod, node}`. `POST /process` echoes the message with the pod and node names. |
| `gateway-service` | `gateway-service/` | Flask on port 5000. `GET /workers` lists the pod addresses the headless Service resolves to. `POST /fanout` sends the message to every worker concurrently and aggregates the replies. |
| Helm chart `fanout` | `helm-chart/` | One worker Deployment (replicas from `values.yaml`) behind a headless Service, plus the gateway Deployment and its LoadBalancer Service. Worker pods prefer different nodes. |

## Prerequisites

Installed where you deploy from (all of them are on the course VM):

- **[Terraform](https://developer.hashicorp.com/terraform/install)** 1.9 or later
- **[Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)**, signed in to the course subscription
- **[Docker](https://docs.docker.com/engine/install/)**
- **[kubectl](https://kubernetes.io/docs/tasks/tools/)**
- **[Helm](https://helm.sh/docs/intro/install/)**

You also need the Azure Container Registry you deployed in Module 4.

## Step 1: Deploy the Cluster with Terraform

You write this Terraform yourself. It must produce:

- A resource group of your own, named to the course convention `dev-jhu-<yourname>-rg-use`.
- One `azurerm_kubernetes_cluster` with `identity { type = "SystemAssigned" }` and a
  `default_node_pool` of one small node (the system pool).
- One `azurerm_kubernetes_cluster_node_pool` in `mode = "User"` with `node_count = 2` or more,
  on a general-purpose CPU size such as `Standard_D2as_v5`.
- One `azurerm_role_assignment` giving the cluster's kubelet identity the `AcrPull` role on your
  registry. The principal is `azurerm_kubernetes_cluster.<name>.kubelet_identity[0].object_id`
  and the scope is the registry's resource ID. This is what lets the cluster pull your images
  with no pull secret.
- Outputs for the cluster name and the resource group name.

Apply it the usual way:

```bash
terraform init
terraform plan  -var-file="student.tfvars.json"
terraform apply -var-file="student.tfvars.json"
```

Then connect and check the nodes:

```bash
az aks get-credentials --resource-group <RESOURCE_GROUP> --name <AKS_CLUSTER_NAME>
kubectl get nodes
```

Every node, system and user, should show `Ready`.

## Step 2: Build and Push the Images

```bash
az acr login --name <ACR_NAME>

cd 705.604/module05/worker-app
docker build -t <ACR_DOMAIN_NAME>/worker-app:<TAG> .
docker push <ACR_DOMAIN_NAME>/worker-app:<TAG>

cd ../gateway-service
docker build -t <ACR_DOMAIN_NAME>/gateway-service:<TAG> .
docker push <ACR_DOMAIN_NAME>/gateway-service:<TAG>
```

`<ACR_DOMAIN_NAME>` is your registry's login server, for example `devjhuexampleacruse.azurecr.io`.

## Step 3: Deploy with Helm

Edit `helm-chart/values.yaml`:

```yaml
acr: <ACR_DOMAIN_NAME>

gateway:
  image: gateway-service
  tag: <TAG>
  port: 5000

worker:
  image: worker-app
  tag: <TAG>
  port: 8000
  replicas: 3
```

Install the chart and watch the pods come up:

```bash
cd 705.604/module05/helm-chart
helm install fanout .
kubectl get pods -o wide
kubectl get service gateway
```

`kubectl get pods -o wide` shows which node each pod landed on. With two or more user nodes
the worker pods spread across them; the chart asks the scheduler to prefer a different node
for each replica. `kubectl get service gateway` shows the external IP once the load balancer
is ready; it can take a minute or two.

## Step 4: Fan Out a Message

```bash
GATEWAY=$(kubectl get service gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

curl -s http://$GATEWAY/workers
curl -s -X POST http://$GATEWAY/fanout \
  -H "Content-Type: application/json" \
  -d '{"message": "hello from <yourname>"}'
```

The response holds one entry per worker pod, each with the pod name, the node name, and your
message. Now scale the workers and call again:

```bash
helm upgrade fanout . --set worker.replicas=5
kubectl get pods -o wide
curl -s -X POST http://$GATEWAY/fanout \
  -H "Content-Type: application/json" \
  -d '{"message": "hello again"}'
```

`worker_count` should now be 5. The gateway never changed; the headless Service simply resolves
to more pods.

Other useful commands:

```bash
helm upgrade fanout .     # after editing values.yaml
helm uninstall fanout
```

## Step 5: Stop the Cluster When You Are Not Using It

Every node bills for every hour it runs. Stop the cluster between work sessions and start it
again when you come back:

```bash
az aks stop  --resource-group <RESOURCE_GROUP> --name <AKS_CLUSTER_NAME>
az aks start --resource-group <RESOURCE_GROUP> --name <AKS_CLUSTER_NAME>
```

Do not commit `terraform.tfstate`, your kubeconfig, or anything holding a registry credential.
