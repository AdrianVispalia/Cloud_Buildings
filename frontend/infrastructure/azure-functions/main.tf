terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example_rg" {
  name     = "example-resources"
  location = "East US"
}

resource "azurerm_storage_account" "example_sa" {
  name                     = "abtcdefaha"
  resource_group_name      = azurerm_resource_group.example_rg.name
  location                 = azurerm_resource_group.example_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "HEAD", "POST", "PUT", "DELETE"]
      allowed_origins    = ["*"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  }
}

resource "azurerm_storage_container" "example_sc" {
  name                  = "mycontainer"
  storage_account_name  = azurerm_storage_account.example_sa.name
  container_access_type = "container"
}



resource "azurerm_linux_function_app" "example_fa" {
  name                = "example-linux-function-app33"
  resource_group_name = azurerm_resource_group.example_rg.name
  location            = azurerm_resource_group.example_rg.location

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "FUNCTIONS_EXTENSION_VERSION" = "~4"
    "FUNCTIONS_WORKER_RUNTIME" = "node"
    "linuxFxVersion" = "Node|18"
    "AzureWebJobsStorage"         = format(
      "DefaultEndpointsProtocol=https;AccountName=%s;AccountKey=%s;EndpointSuffix=core.windows.net",
      azurerm_storage_account.example_sa.name,
      azurerm_storage_account.example_sa.primary_access_key
    )
  }

  storage_account_name       = azurerm_storage_account.example_sa.name
  storage_account_access_key = azurerm_storage_account.example_sa.primary_access_key
  service_plan_id            = azurerm_service_plan.example_sp.id

  site_config {
    use_32_bit_worker = false
      application_stack  {
        node_version = "18"
    }
  }
}

resource "azurerm_service_plan" "example_sp" {
  name                = "example"
  resource_group_name = azurerm_resource_group.example_rg.name
  location            = azurerm_resource_group.example_rg.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

output "sa_blob_storage_endpoint" {
  value = azurerm_storage_account.example_sa.primary_blob_endpoint
}

output "sa_blob_storage_endpoint2" {
  value = azurerm_storage_account.example_sa.primary_blob_internet_endpoint
}

output "sa_web_endpoint" {
  value = azurerm_storage_account.example_sa.primary_web_endpoint
}

output "sa_web_endpoint2" {
  value = azurerm_storage_account.example_sa.primary_web_internet_endpoint
}
