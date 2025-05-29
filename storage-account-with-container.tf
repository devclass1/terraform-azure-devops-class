# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Get user input for storage account and container names
locals {
  storage_account_name = var.storage_account_name
  container_name      = var.container_name
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "storage-rg"
  location = "eastus"
}

# Create the storage account
resource "azurerm_storage_account" "example" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = true

  tags = {
    environment = "demo"
  }
}

# Create a container with public access
resource "azurerm_storage_container" "example" {
  name                  = local.container_name
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "blob" # Options: "private", "blob", "container"
}

# Output the storage account URL and container URL
output "storage_account_url" {
  value = azurerm_storage_account.example.primary_blob_endpoint
}

output "container_url" {
  value = "${azurerm_storage_account.example.primary_blob_endpoint}${local.container_name}"
}

# Variable definitions
variable "storage_account_name" {
  description = "The name of the Azure Storage Account (3-24 chars, lowercase alphanumeric)"
  type        = string
}

variable "container_name" {
  description = "The name of the container to create (3-63 chars, lowercase alphanumeric)"
  type        = string
}
