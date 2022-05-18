provider "azurerm" {
  features { 
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
