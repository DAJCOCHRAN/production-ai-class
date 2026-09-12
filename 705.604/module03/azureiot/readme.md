# IOT Bus Example

1. client-listener.py - Listens for IOT device messages
1. freezer_garage-producer.py - IOT device for freezer temperature in garage and on remote Orin device
1. freezer_kitchen-producer.py - IOT device for freezer temperature in kitchen on remote Raspberry Pi 5

## Setup

The scripts read every key from an environment variable loaded from a `.env`
file. No keys are stored in this repo; you supply your own from an IoT Hub in
your Azure subscription and from your Govee developer account.

| Variable | Used by | Where it comes from |
|---|---|---|
| `IOTHUB_DEVICE_CONNECTION_STR` | producers | IoT Hub > Devices > your device |
| `GOVEE_API_KEY` | producers | Govee Home app, developer API key |
| `IOTHUB_EVENTHUB_CONNECTION_STR` | listener | IoT Hub > Built-in endpoints |
| `IOTHUB_EVENTHUB_NAME` | listener | IoT Hub > Built-in endpoints |

### 1. Create an IoT Hub (if you don't have one)

1. Sign in to the [Azure portal](https://portal.azure.com).
1. Search for **IoT Hub** and click **Create**.
1. Pick your subscription and resource group, give the hub a unique name, choose
   a region, and pick a tier. The **Free** tier (F1) is enough for this
   example, but each subscription may only have one free hub.
1. Click **Review + create**, then **Create**.

Or with the Azure CLI:

```bash
az extension add --name azure-iot
az iot hub create --resource-group <rg> --name <hub> --sku F1 --partition-count 2
```

### 2. Register a device and get its connection string (producers)

Each producer script runs on a different physical device, so register one
device per script (for example `freezer-garage` and `freezer-kitchen`).

1. Open your IoT Hub in the portal.
1. In the left menu choose **Device management > Devices**, then **Add Device**.
1. Enter a Device ID, leave **Symmetric key** and **Auto-generate keys**
   selected, and click **Save**.
1. Click the new device and copy **Primary connection string**. It looks like
   `HostName=<hub>.azure-devices.net;DeviceId=<device>;SharedAccessKey=...`

Or with the Azure CLI:

```bash
az iot hub device-identity create --hub-name <hub> --device-id freezer-garage
az iot hub device-identity connection-string show --hub-name <hub> --device-id freezer-garage --output tsv
```

### 3. Get the Govee API key (producers)

The producers read freezer temperatures from Govee thermometers through the
Govee Developer API.

1. Open the **Govee Home** app on your phone.
1. Go to the profile tab, then **Settings > Apply for API Key**.
1. Fill in the short form. The key is emailed to you, usually within minutes.

The Govee device SKU and MAC address used by each producer are set in the
`get_deviceState(...)` call near the bottom of the script. Replace them with
your own devices, which you can list by calling `recorder.get_devices()`.

### 4. Get the Event Hub-compatible endpoint (listener)

IoT Hub exposes the device-to-cloud message stream through a built-in endpoint
that speaks the Event Hubs protocol. The listener connects to that.

1. Open your IoT Hub in the portal.
1. In the left menu choose **Hub settings > Built-in endpoints**.
1. Under **Event Hub compatible endpoint**, pick the **iothubowner** shared
   access policy and copy **Event Hub-compatible endpoint**. It looks like
   `Endpoint=sb://...servicebus.windows.net/;SharedAccessKeyName=iothubowner;SharedAccessKey=...;EntityPath=<hub>`
1. On the same page copy **Event Hub-compatible name** (normally the hub name).

Or with the Azure CLI:

```bash
az iot hub connection-string show --hub-name <hub> --default-eventhub --policy-name iothubowner --output tsv
```

### 5. Put the values in a `.env` file

```bash
cp .env.example .env
```

Edit `.env` and paste in your values. On the Orin and the Raspberry Pi, each
device's `.env` gets its own device connection string. The repo's `.gitignore`
excludes `.env`, so your keys stay off GitHub. Never paste a key into a script
or commit it.

### 6. Install the Python packages

```bash
pip install -r requirements.txt
```

Run `client-listener.py` first on your workstation, then start a producer on
each device and watch the temperature messages arrive.
