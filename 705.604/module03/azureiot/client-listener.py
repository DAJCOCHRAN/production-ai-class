# Install: pip install -r requirements.txt

import os
from dotenv import load_dotenv
from azure.eventhub import EventHubConsumerClient

# Load the IoT Hub Event Hub-compatible endpoint from a .env file (see readme.md for how to get it).
load_dotenv()
IOTHUB_EVENTHUB_CONNECTION_STR = os.getenv("IOTHUB_EVENTHUB_CONNECTION_STR")
if not IOTHUB_EVENTHUB_CONNECTION_STR:
    raise SystemExit("IOTHUB_EVENTHUB_CONNECTION_STR is not set. Copy .env.example to .env and fill it in (see readme.md).")
IOTHUB_EVENTHUB_NAME = os.getenv("IOTHUB_EVENTHUB_NAME")
if not IOTHUB_EVENTHUB_NAME:
    raise SystemExit("IOTHUB_EVENTHUB_NAME is not set. Copy .env.example to .env and fill it in (see readme.md).")

def on_event(partition_context, event):
    print("Received event: ", event.body_as_str())
    
    partition_context.update_checkpoint(event)

client = EventHubConsumerClient.from_connection_string(
    conn_str=IOTHUB_EVENTHUB_CONNECTION_STR,
    consumer_group="$Default",
    eventhub_name=IOTHUB_EVENTHUB_NAME
)

print("Listening for events...")
with client:
    client.receive(on_event=on_event, starting_position="-1")
