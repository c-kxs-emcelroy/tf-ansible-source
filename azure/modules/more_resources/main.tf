data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "example_keyvault" {
  name                        = "${var.prefix}-keyvault"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "Backup",
      "Create",
      "Decrypt",
      "Delete",
      "Encrypt",
      "Import",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Sign",
      "UnwrapKey",
      "Update",
      "Verify",
      "WrapKey"
    ]

    secret_permissions = [
      "Backup",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Set"
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "azurerm_key_vault_secret" "ssh_key" {
  name = "vm_key"
  value = tls_private_key.example_ssh.private_key_openssh
  key_vault_id = azurerm_key_vault.example_keyvault
  
}

resource "azurerm_key_vault_secret" "ssh_public_key" {
  name = "vm_public_key"
  value = tls_private_key.example_ssh.public_key_openssh
  key_vault_id = azurerm_key_vault.example_keyvault
}