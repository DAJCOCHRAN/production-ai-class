# JHU Production AI - Module 07: Azure Storage for AI Workloads

In this module we deploy an Azure Storage Account using Terraform and walk through a practical AI use case: storing training data as blobs and pulling that data into a Python script for model training.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Azure Resource Group                               │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                     Azure Storage Account                             │  │
│  │                     (Standard LRS, Versioning)                        │  │
│  │                                                                       │  │
│  │   ┌─────────────────────────┐    ┌──────────────────────────────┐    │  │
│  │   │   training-data         │    │   model-artifacts             │    │  │
│  │   │   Container             │    │   Container                   │    │  │
│  │   │                         │    │                               │    │  │
│  │   │   - iris_dataset.csv    │    │   - iris_rf_model.joblib      │    │  │
│  │   │   - (your datasets)     │    │   - (your trained models)     │    │  │
│  │   └─────────────────────────┘    └──────────────────────────────┘    │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Deployment Flow

```
┌──────────────┐     ┌──────────────────┐     ┌──────────────────────────────┐
│              │     │                  │     │                              │
│  Terraform   │────>│  Azure Storage   │────>│  Python Scripts              │
│  deploy.ps1  │     │  Account         │     │  (AI Training Pipeline)      │
│              │     │  + Containers    │     │                              │
└──────────────┘     └──────────────────┘     └──────────────────────────────┘
                                                │
                    ┌───────────────────────────────────────────────┐
                    │                                               │
                    ▼                                               ▼
        ┌───────────────────┐                          ┌──────────────────────┐
        │  1. Upload Data   │                          │  2. Train Model      │
        │                   │                          │                      │
        │  Generate Iris    │    Blob Storage           │  Download CSV from   │
        │  dataset as CSV  ─┼──> training-data ────────>│  training-data       │
        │                   │    container              │                      │
        │  upload_training  │                          │  Train RandomForest   │
        │  _data.py         │                          │  classifier           │
        └───────────────────┘                          │                      │
                                                       │  Evaluate accuracy    │
                                                       │                      │
                                                       │  Upload model to ────┼──> model-artifacts
                                                       │  blob storage        │    container
                                                       │                      │
                                                       │  train_model.py      │
                                                       └──────────────────────┘
```

## Pipeline Summary

```
 STEP 1: PROVISION                STEP 2: UPLOAD DATA            STEP 3: TRAIN & STORE
 ─────────────────                ──────────────────             ─────────────────────

 ┌─────────────┐                  ┌─────────────┐               ┌─────────────┐
 │  Terraform  │   deploy.ps1    │  Python     │  upload.py    │  Python     │  train.py
 │  IaC        │ ──────────────> │  SDK        │ ────────────> │  sklearn    │ ──────────>
 │             │  Creates:       │             │  Uploads:     │             │  Outputs:
 │  - RG       │  - Storage Acct │  - Iris CSV │  - Blob      │  - Model    │  - Metrics
 │  - Storage  │  - Containers   │  - Dataset  │  - to Azure  │  - Trained  │  - .joblib
 └─────────────┘                  └─────────────┘               └─────────────┘
                                        │                             │
                                        ▼                             ▼
                                  ┌───────────┐               ┌───────────────┐
                                  │ training- │               │ model-        │
                                  │ data      │               │ artifacts     │
                                  │ container │               │ container     │
                                  └───────────┘               └───────────────┘
```

## Prerequisites

Before starting this module, ensure you have the following installed on your local machine:

- **[Terraform](https://developer.hashicorp.com/terraform/install)** - Infrastructure as Code tool for deploying Azure resources
- **[Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)** - Command-line tool for authenticating and managing Azure resources
- **[Python 3.9+](https://www.python.org/downloads/)** - Required for the AI training example scripts

Ensure you are logged in to Azure:

```bash
az login
```

## Topics

This module contains the following topics that are recommended to be completed in order:

1. [Deploy Storage Account](./docs/StorageAccount.md)
2. [AI Training Pipeline Example](./docs/AITrainingExample.md)
