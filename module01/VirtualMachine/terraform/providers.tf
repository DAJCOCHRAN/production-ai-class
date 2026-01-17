# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.4.0"
    }

		azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  resource_provider_registrations = "none"
  subscription_id = var.studentSubscriptionId
  features {}
}