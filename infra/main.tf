terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.26.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.20.0"
    }
  }
  backend "azurerm" {
    key = "prod.terraform.tfstate"
  }
}

provider "azuread" {
}

provider "azurerm" {
  features {
  }
}

locals {
  rg     = "test-functions"
  region = "australia east"
}

resource "azurerm_storage_account" "example" {
  name                             = "testfunctions8eb8"
  resource_group_name              = local.rg
  location                         = local.region
  account_tier                     = "Standard"
  account_replication_type         = "LRS"
  account_kind                     = "Storage"
  cross_tenant_replication_enabled = false
}

resource "azurerm_service_plan" "example" {
  name                = "ASP-testfunctions-9270"
  resource_group_name = local.rg
  location            = local.region
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "example" {
  name                = "4d76c18f-9e23-4de0-aabe-aeb220aae816"
  resource_group_name = local.rg
  location            = local.region

  builtin_logging_enabled    = false
  client_certificate_mode    = "Required"
  https_only                 = true
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  service_plan_id            = azurerm_service_plan.example.id

  site_config {
    ftps_state = "FtpsOnly"
    application_stack {
      java_version = 11
    }
    cors {
      allowed_origins = [
      ]
    }
  }
}