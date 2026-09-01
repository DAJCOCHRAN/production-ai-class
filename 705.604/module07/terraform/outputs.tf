output "storage_account_name" {
  value = azurerm_storage_account.studentStorageAccount.name
}

output "storage_account_primary_connection_string" {
  value     = azurerm_storage_account.studentStorageAccount.primary_connection_string
  sensitive = true
}

output "training_data_container_name" {
  value = azurerm_storage_container.trainingData.name
}

output "model_artifacts_container_name" {
  value = azurerm_storage_container.modelArtifacts.name
}
