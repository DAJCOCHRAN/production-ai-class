resource "azurerm_storage_account" "studentStorageAccount" {
  name                     = var.studentStorageAccountName
  resource_group_name      = azurerm_resource_group.studentRG.name
  location                 = azurerm_resource_group.studentRG.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  blob_properties {
    versioning_enabled = true
  }

  depends_on = [azurerm_resource_group.studentRG]
}

# Container for storing raw training datasets (CSVs, images, etc.)
resource "azurerm_storage_container" "trainingData" {
  name                  = var.studentTrainingDataContainerName
  storage_account_id    = azurerm_storage_account.studentStorageAccount.id
  container_access_type = "private"
}

# Container for storing trained model artifacts (weights, checkpoints, etc.)
resource "azurerm_storage_container" "modelArtifacts" {
  name                  = var.studentModelArtifactsContainerName
  storage_account_id    = azurerm_storage_account.studentStorageAccount.id
  container_access_type = "private"
}
