import asyncio
from azure.servicebus.aio import ServiceBusClient
import time

import os
from dotenv import load_dotenv

# Load the Service Bus connection string from a .env file (see readme.md for how to get it).
load_dotenv()
NAMESPACE_CONNECTION_STR = os.getenv("SERVICEBUS_CONNECTION_STR")
if not NAMESPACE_CONNECTION_STR:
    raise SystemExit("SERVICEBUS_CONNECTION_STR is not set. Copy .env.example to .env and fill it in (see readme.md).")
QUEUE_NAME = "testqueue"
#ServiceBusClient.renewer.register(receiver, receiver.session, max_lock_renewal_duration=100)

#print('Register session into AutoLockRenewer.')

async def run():
    # create a Service Bus client using the connection string
    while(True):
        async with ServiceBusClient.from_connection_string(
            conn_str=NAMESPACE_CONNECTION_STR,
            logging_enable=True) as servicebus_client:

            async with servicebus_client:
                # get the Queue Receiver object for the queue
                receiver = servicebus_client.get_queue_receiver(queue_name=QUEUE_NAME)
                async with receiver:
                    received_msgs = await receiver.receive_messages(max_wait_time=5, max_message_count=10)
                    for msg in received_msgs:
                        print("Received: " + str(msg))
                        # complete the message so that the message is removed from the queue
                        await receiver.complete_message(msg)
                        #time.sleep(2)
asyncio.run(run())
                    
                    