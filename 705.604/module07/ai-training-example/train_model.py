"""
Train a Model Using Data from Azure Blob Storage

This script demonstrates a basic AI/ML workflow:
1. Download a training dataset (CSV) from Azure Blob Storage
2. Train a simple classification model (Random Forest on Iris data)
3. Evaluate the model and print metrics
4. Upload the trained model artifact back to Azure Blob Storage

Usage:
    python train_model.py
"""

import os
import io
import joblib
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, accuracy_score
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


def download_blob_to_dataframe(blob_service_client, container_name, blob_name):
    """Download a CSV blob and return it as a pandas DataFrame."""
    container_client = blob_service_client.get_container_client(container_name)
    blob_client = container_client.get_blob_client(blob_name)
    blob_data = blob_client.download_blob().readall()
    print(f"Downloaded '{blob_name}' from container '{container_name}' ({len(blob_data)} bytes)")
    return pd.read_csv(io.BytesIO(blob_data))


def train_random_forest(df):
    """Train a Random Forest classifier on the Iris dataset."""
    X = df.drop(columns=["target"])
    y = df["target"]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    model = RandomForestClassifier(n_estimators=100, random_state=42)
    model.fit(X_train, y_train)

    y_pred = model.predict(X_test)

    print("\n--- Model Evaluation ---")
    print(f"Accuracy: {accuracy_score(y_test, y_pred):.4f}")
    print(f"\nClassification Report:\n{classification_report(y_test, y_pred)}")

    return model


def upload_model(blob_service_client, container_name, model_name, model):
    """Serialize the model and upload it to blob storage."""
    buf = io.BytesIO()
    joblib.dump(model, buf)
    buf.seek(0)

    container_client = blob_service_client.get_container_client(container_name)
    blob_client = container_client.get_blob_client(model_name)
    blob_client.upload_blob(buf.getvalue(), overwrite=True)
    print(f"\nUploaded trained model '{model_name}' to container '{container_name}'")


def main():
    training_container = os.environ.get("TRAINING_DATA_CONTAINER", "training-data")
    model_container = os.environ.get("MODEL_ARTIFACTS_CONTAINER", "model-artifacts")

    blob_service_client = get_blob_service_client()

    # Step 1: Download training data from blob storage
    print("=== Step 1: Downloading training data ===")
    df = download_blob_to_dataframe(
        blob_service_client, training_container, "iris_dataset.csv"
    )
    print(f"Dataset shape: {df.shape}")
    print(f"Columns: {list(df.columns)}")

    # Step 2: Train the model
    print("\n=== Step 2: Training Random Forest model ===")
    model = train_random_forest(df)

    # Step 3: Upload model artifact back to blob storage
    print("\n=== Step 3: Uploading model artifact ===")
    upload_model(blob_service_client, model_container, "iris_rf_model.joblib", model)

    print("\nDone! Full pipeline complete:")
    print("  Blob Storage (training data) -> Train Model -> Blob Storage (model artifact)")


if __name__ == "__main__":
    main()
