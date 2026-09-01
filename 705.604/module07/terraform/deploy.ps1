#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$TfVarsFile = Join-Path $ScriptDir "student.tfvars.json"

Push-Location $ScriptDir

try {
    # --- Pre-flight checks ---

    if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
        Write-Error "terraform is not installed. Install it from https://developer.hashicorp.com/terraform/install"
    }

    if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
        Write-Error "Azure CLI is not installed. Install it from https://learn.microsoft.com/en-us/cli/azure/install-azure-cli"
    }

    # Verify Azure CLI login
    $azAccount = az account show 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Not logged in to Azure. Run 'az login' first."
    }

    if (-not (Test-Path $TfVarsFile)) {
        Write-Error "Variable file not found at $TfVarsFile"
    }

    # Check that the student has replaced the placeholder subscription ID
    $varsContent = Get-Content $TfVarsFile -Raw | ConvertFrom-Json
    $subId = $varsContent.studentSubscriptionId

    if ($subId -eq "YOUR_SUBSCRIPTION_ID" -or [string]::IsNullOrWhiteSpace($subId)) {
        Write-Host "ERROR: Update 'studentSubscriptionId' in student.tfvars.json with your Azure subscription ID." -ForegroundColor Red
        Write-Host "       You can find it with: az account show --query id -o tsv" -ForegroundColor Yellow
        exit 1
    }

    Write-Host "=== Terraform Deploy - Module 07: Storage Account ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Subscription: $subId"
    Write-Host "Var file:     $TfVarsFile"
    Write-Host ""

    # --- Init ---
    Write-Host "--- terraform init ---" -ForegroundColor Green
    terraform init
    if ($LASTEXITCODE -ne 0) { Write-Error "terraform init failed" }

    # --- Plan ---
    Write-Host ""
    Write-Host "--- terraform plan ---" -ForegroundColor Green
    terraform plan -var-file="$TfVarsFile" -out=tfplan
    if ($LASTEXITCODE -ne 0) { Write-Error "terraform plan failed" }

    # --- Confirm ---
    Write-Host ""
    $confirm = Read-Host "Apply this plan? (yes/no)"
    if ($confirm -ne "yes") {
        Write-Host "Aborted." -ForegroundColor Yellow
        Remove-Item -Path tfplan -ErrorAction SilentlyContinue
        exit 0
    }

    # --- Apply ---
    Write-Host ""
    Write-Host "--- terraform apply ---" -ForegroundColor Green
    terraform apply tfplan
    if ($LASTEXITCODE -ne 0) { Write-Error "terraform apply failed" }
    Remove-Item -Path tfplan -ErrorAction SilentlyContinue

    # --- Output connection string ---
    Write-Host ""
    Write-Host "=== Deployment complete ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To set the connection string for the AI training example, run:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host '  $env:AZURE_STORAGE_CONNECTION_STRING = (terraform output -raw storage_account_primary_connection_string)'
    Write-Host ""
}
finally {
    Pop-Location
}
