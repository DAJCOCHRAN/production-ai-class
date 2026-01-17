# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.14.0"
    }

    azapi = {
      source  = "azure/azapi"
      version = "~> 2.2"
    }
  }

  required_version = ">= 1.9.0"
}

provider "azurerm" {
  resource_provider_registrations = "none"
  subscription_id = var.studentSubscriptionId
  features {}
}