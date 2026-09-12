# Four communication methods
1. Azure IOT Hub
1. Azure Message Bus
1. RabbitMQ
1. Kafka

## Keys and connection strings

None of the examples contain keys. The Azure examples read their connection
strings from a `.env` file that git ignores. Each folder has a `.env.example`
to copy and a `readme.md` explaining where to get the values in the Azure portal
or with the Azure CLI. Kafka and RabbitMQ run locally in Docker and need no keys.
