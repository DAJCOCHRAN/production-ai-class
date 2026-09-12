# Azure Service Bus using Queues and Topics

## Setup

The scripts read the Service Bus connection string from an environment variable
called `SERVICEBUS_CONNECTION_STR`. No keys are stored in this repo; you supply
your own from a Service Bus namespace in your Azure subscription.

### 1. Create a Service Bus namespace (if you don't have one)

1. Sign in to the [Azure portal](https://portal.azure.com).
1. Search for **Service Bus** and click **Create**.
1. Pick your subscription and resource group, give the namespace a unique name,
   choose a region, and select the **Standard** pricing tier (topics require
   Standard or higher; Basic only supports queues).
1. Click **Review + create**, then **Create**.

Or with the Azure CLI:

```bash
az servicebus namespace create --resource-group <rg> --name <namespace> --location eastus --sku Standard
```

### 2. Create the queue, topic, and subscription the scripts expect

In the namespace, use **Entities > Queues** and **Entities > Topics**, or run:

```bash
az servicebus queue create --resource-group <rg> --namespace-name <namespace> --name testqueue
az servicebus topic create --resource-group <rg> --namespace-name <namespace> --name testtopic
az servicebus topic subscription create --resource-group <rg> --namespace-name <namespace> \
    --topic-name testtopic --name subscriptiontopic
```

The names `testqueue`, `testtopic`, and `subscriptiontopic` are set near the top
of each script. Change them there if you use different names.

### 3. Get the connection string

1. Open your Service Bus namespace in the Azure portal.
1. In the left menu choose **Settings > Shared access policies**.
1. Click **RootManageSharedAccessKey** (or create a policy with Send and
   Listen rights if you'd rather not use the root key).
1. Copy the **Primary Connection String**. It looks like
   `Endpoint=sb://<namespace>.servicebus.windows.net/;SharedAccessKeyName=...;SharedAccessKey=...`

Or with the Azure CLI:

```bash
az servicebus namespace authorization-rule keys list --resource-group <rg> \
    --namespace-name <namespace> --name RootManageSharedAccessKey \
    --query primaryConnectionString --output tsv
```

### 4. Put the connection string in a `.env` file

```bash
cp .env.example .env
```

Edit `.env` and paste the connection string after `SERVICEBUS_CONNECTION_STR=`.
The repo's `.gitignore` excludes `.env`, so your key stays off GitHub. Never
paste the key into a script or commit it.

### 5. Install the Python packages

```bash
pip install -r requirements.txt
```

## Queue
1. serviceBusQueueRecieve.py - Waits to receive a message off the queue.  Run multiple copies of this to see that each receiver gets different messages.
1. serviceBusQueueSend.py - Sends out a sequence of numbered messages.

## Topic
1. serviceBusTopicRecieve.py - Receives ALL the topic messages even if multiple versions are run.  Each one will receive all the messages for that topic from this subscription.
1. serviceBusTopicRecieve2.py - Same as above; run it alongside serviceBusTopicRecieve.py to see both receivers get every message.
1. serviceBusTopicSend.py - Sends out a sequence of messages to the given topic.
