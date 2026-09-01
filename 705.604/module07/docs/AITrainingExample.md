# AI Training Pipeline with Azure Blob Storage

## Overview

This guide walks through a basic AI/ML workflow that uses Azure Blob Storage as the data layer:

1. **Upload** a training dataset (CSV) to blob storage
2. **Download** the dataset from blob storage into a Python script
3. **Train** a Random Forest classifier on the data
4. **Upload** the trained model artifact back to blob storage

This pattern is common in production AI systems where training data lives in cloud storage and model artifacts are persisted for later deployment or inference.

## Prerequisites

- Completed the [Storage Account deployment](./StorageAccount.md)
- Python 3.9+ installed
- The storage account connection string from Step 5 of the deployment guide

## Step 1: Set Up Python Environment

Navigate to the example directory:

```bash
cd 705.604/module07/ai-training-example
```

Create and activate a virtual environment:

```bash
python -m venv .venv
source .venv/bin/activate    # Linux/Mac
# .venv\Scripts\activate     # Windows
```

Install dependencies:

```bash
pip install -r requirements.txt
```

## Step 2: Set the Connection String

The Python scripts read the storage account connection string from a file called `connectionstring.txt` in the `ai-training-example` directory.

If you already created this file during the [Storage Account deployment](./StorageAccount.md#step-5-retrieve-the-connection-string), you can skip this step.

Otherwise, generate it from Terraform:

```powershell
cd ../terraform
terraform output -raw storage_account_primary_connection_string > ../ai-training-example/connectionstring.txt
cd ../ai-training-example
```

Or create the file manually — paste your connection string as the only line:

```
705.604/module07/ai-training-example/connectionstring.txt
```

> **Important**: This file contains your storage account access key. It is included in `.gitignore` and should never be committed to source control.

## Step 3: Upload Training Data

Run the upload script to generate the Iris dataset and upload it as a CSV blob:

```bash
python upload_training_data.py
```

Expected output:

```
Generating Iris dataset...
Uploaded 'iris_dataset.csv' to container 'training-data'

Blobs in container:
  - iris_dataset.csv (2871 bytes)
```

You can also verify the blob exists in the Azure Portal by navigating to your Storage Account > Containers > training-data.

## Step 4: Train the Model

Run the training script, which downloads the data from blob storage, trains a Random Forest model, and uploads the model artifact:

```bash
python train_model.py
```

Expected output:

```
=== Step 1: Downloading training data ===
Downloaded 'iris_dataset.csv' from container 'training-data' (2871 bytes)
Dataset shape: (150, 5)
Columns: ['sepal length (cm)', 'sepal width (cm)', 'petal length (cm)', 'petal width (cm)', 'target']

=== Step 2: Training Random Forest model ===

--- Model Evaluation ---
Accuracy: 1.0000

Classification Report:
              precision    recall  f1-score   support
...

=== Step 3: Uploading model artifact ===
Uploaded trained model 'iris_rf_model.joblib' to container 'model-artifacts'

Done! Full pipeline complete:
  Blob Storage (training data) -> Train Model -> Blob Storage (model artifact)
```

## What You Learned

This example demonstrates a fundamental pattern used in production AI systems:

```
┌──────────────┐       ┌──────────────┐       ┌──────────────┐
│  Raw Data    │──────>│  Training    │──────>│  Model       │
│  (Blob)      │       │  Script      │       │  Artifact    │
│              │       │              │       │  (Blob)      │
│ training-data│       │ scikit-learn │       │ model-       │
│ container    │       │ RandomForest │       │ artifacts    │
└──────────────┘       └──────────────┘       └──────────────┘
```

In real-world scenarios:
- **Training data** could be images, audio files, large CSVs, or Parquet files stored in blob storage
- **Training** could happen on a GPU VM, AKS cluster, or Azure ML compute
- **Model artifacts** stored in blob storage can be pulled by inference services for serving predictions
- **Blob versioning** (enabled in our Terraform config) tracks dataset and model versions over time
