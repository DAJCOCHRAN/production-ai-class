"""
Upload Training Data to Azure Blob Storage

This script demonstrates how to:
1. Generate a sample CSV dataset (Iris-style classification data)
2. Upload it as a blob to an Azure Storage container

Usage:
    python upload_training_data.py
"""

import os
import io
import pandas as pd
from sklearn.datasets import load_iris
from azure.storage.blob import BlobServiceClient


def get_blob_service_client():
    secret_file = os.path.join(os.path.dirname(__file__), "connectionstring.txt")
    if not os.path.exists(secret_file):
        raise FileNotFoundError(
            f"Connection string file not found: {secret_file}\n"
            "Create connectionstring.txt with your storage account connection string.\n"
            "You can retrieve it with:\n"
            "  terraform output -raw storage_account_primary_connection_string"
        )
    connection_string = open(secret_file).read().strip()
    return BlobServiceClient.from_connection_string(connection_string)


def generate_iris_csv() -> bytes:
    """Load the Iris dataset and return it as CSV bytes."""
    iris = load_iris(as_frame=True)
    df = iris.frame
    buf = io.BytesIO()
    df.to_csv(buf, index=False)
    return buf.getvalue()


def upload_blob(blob_service_client, container_name, blob_name, data):
    """Upload bytes data to a blob."""
    container_client = blob_service_client.get_container_client(container_name)
    blob_client = container_client.get_blob_client(blob_name)
    blob_client.upload_blob(data, overwrite=True)
    print(f"Uploaded '{blob_name}' to container '{container_name}'")


def main():
    container_name = os.environ.get("TRAINING_DATA_CONTAINER", "training-data")

    blob_service_client = get_blob_service_client()

    # Generate and upload the Iris dataset as a CSV
    print("Generating Iris dataset...")
    csv_data = generate_iris_csv()
    upload_blob(blob_service_client, container_name, "iris_dataset.csv", csv_data)

    # List blobs to confirm the upload
    container_client = blob_service_client.get_container_client(container_name)
    print("\nBlobs in container:")
    for blob in container_client.list_blobs():
        print(f"  - {blob.name} ({blob.size} bytes)")


if __name__ == "__main__":
    main()
