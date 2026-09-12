import os
import requests
import json
from dotenv import load_dotenv
from azure.iot.device import IoTHubDeviceClient, Message
import time

# Load the IoT Hub device connection string and Govee API key from a .env file
# (see readme.md for how to get them).
load_dotenv()
IOTHUB_DEVICE_CONNECTION_STR = os.getenv("IOTHUB_DEVICE_CONNECTION_STR")
if not IOTHUB_DEVICE_CONNECTION_STR:
    raise SystemExit("IOTHUB_DEVICE_CONNECTION_STR is not set. Copy .env.example to .env and fill it in (see readme.md).")
GOVEE_API_KEY = os.getenv("GOVEE_API_KEY")
if not GOVEE_API_KEY:
    raise SystemExit("GOVEE_API_KEY is not set. Copy .env.example to .env and fill it in (see readme.md).")

device_client = IoTHubDeviceClient.create_from_connection_string(IOTHUB_DEVICE_CONNECTION_STR)

coreurl =  "https://openapi.api.govee.com"
getDevicesurl = "/router/api/v1/user/devices"
getStateurl = "/router/api/v1/device/state"

headers = {
      "Content-Type":"application/json",
      "Govee-API-Key": GOVEE_API_KEY
}


payload = {
    "requestId": "uuid",
    "payload": {
        "sku": "H5111",
        "device": "63:15:E1:3D:05:46:47:16"
    }
}

class iotrecorderStatefull:
    def __init__(self):
        self.data = []

    def record(self, data):
        self.data.append(data)

    def get_devices(self):
        return requests.get(coreurl+getDevicesurl, headers=headers)
    
    def get_deviceState(self, sku,device):
        payload = {
            "requestId":"uuid",
            "payload": {
                "sku": sku,
                "device": device
            }
        }
        payloadJson = json.dumps(payload)
        return requests.post(coreurl+getStateurl, headers=headers, data=payloadJson)

    def clear_data(self):
        self.data = []
        
if __name__ == "__main__":
    recorder = iotrecorderStatefull()
    response = recorder.get_devices()

    device_data = response.json()

    prettydevice = json.dumps(device_data, indent=4)
    #print(prettydevice)
    
    for i in range(1, 11):
        #print("\n\n ***** Getting Device State for *****\n\n")
        device_state = recorder.get_deviceState("H5111", "63:15:E1:3D:05:46:47:16")
        device_state_data = device_state.json()
        prettystate = json.dumps(device_state_data, indent=4)
        #print(prettystate)
        device_data = json.loads(prettystate)
        value = device_data["payload"]["capabilities"][1]["state"]["value"]
       
        message = Message( f'{{"messageIndex": "{i}", "temperature": {value}, "device":"Orin Garage Freezer"}}' )
        device_client.send_message(message)
        print(f"Message {i} sent! with value {value}")
        time.sleep(10)
  
 