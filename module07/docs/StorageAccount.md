# Deploying an Azure Storage Account with Terraform

## Overview

In this guide you will use Terraform to deploy an Azure Storage Account with two blob containers:

- **training-data** - for storing raw datasets used in AI/ML model training
- **model-artifacts** - for storing trained model outputs (weights, checkpoints)

## Step 1: Configure Your Variables

Navigate to the Terraform directory:

```bash
cd module07/terraform
```

Open `student.tfvars.json` and replace the placeholder values with your own:

```json
{
  "studentSubscriptionId": "YOUR_SUBSCRIPTION_ID",
  "studentRGName": "dev-jhu-yourname-rg-use",
  "studentStorageAccountName": "devjhuyournamestuse"
}
```

> **Important**: Storage account names must be globally unique, 3-24 characters, and contain only lowercase letters and numbers. No hyphens or special characters are allowed.

## Step 2: Initialize Terraform

```bash
terraform init
```

You should see a message confirming the Azure provider was installed successfully.

## Step 3: Plan the Deployment

```bash
terraform plan -var-file="student.tfvars.json"
```

Review the output. You should see Terraform plans to create:
- 1 Resource Group
- 1 Storage Account
- 2 Storage Containers (`training-data` and `model-artifacts`)

## Step 4: Apply the Deployment

```bash
terraform apply -var-file="student.tfvars.json"
```

Type `yes` when prompted to confirm.

## Step 5: Retrieve the Connection String

After the deployment completes, retrieve the storage account connection string and save it to `connectionstring.txt` (the Python scripts read from this file):

```powershell
terraform output -raw storage_account_primary_connection_string > ../ai-training-example/connectionstring.txt
```

Or retrieve it manually and paste it into the file:

```powershell
terraform output -raw storage_account_primary_connection_string
```

Then create `module07/ai-training-example/connectionstring.txt` and paste the value as the only line in the file.

> **Important**: `connectionstring.txt` is included in `.gitignore` and should never be committed to source control. It contains your storage account access key.

## Step 6: Verify in the Azure Portal

Navigate to the [Azure Portal](https://portal.azure.com) and confirm:
1. Your Resource Group was created
2. The Storage Account exists inside it
3. Two blob containers (`training-data` and `model-artifacts`) are present

## Cleanup

When you are done with the module, destroy the resources to avoid ongoing charges:

```bash
terraform destroy -var-file="student.tfvars.json"
```

Type `yes` when prompted.
