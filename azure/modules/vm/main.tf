# Generate a random suffix to suffix resources with
data "azurerm_key_vault" "disk_vault" {
  name                = var.keyvault_name
  resource_group_name = var.resource_group_name

}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "azurerm_public_ip" "example_ip" {
  name                    = "${var.prefix}-public-ip-${random_id.suffix.hex}"
  location                = var.location
  resource_group_name     = var.resource_group_name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
}

resource "azurerm_network_interface" "example_interface" {
  name                = "${var.prefix}-nic-${random_id.suffix.hex}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.prefix}-internal-ip-${random_id.suffix.hex}"
    subnet_id                     = var.subnet
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example_ip.id

  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "${var.prefix}-vm-${random_id.suffix.hex}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.instance_type
  admin_username      = var.admin_user
  network_interface_ids = [
    azurerm_network_interface.example_interface.id,
  ]

  admin_ssh_key {
    username   = var.admin_user
    public_key = var.admin_key_public
  }

  os_disk {
    name                          =     "${var.prefix}-vm-os-disk"
    caching                       =     "ReadWrite"
    storage_account_type          =     "StandardSSD_LRS"
    disk_size_gb                  =     64

  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9-gen2"
    version   = "latest"
  }
}

resource "azurerm_key_vault_key" "disk_key" {
    name                            =       "${var.prefix}-vm-ade-kek"
    key_vault_id                    =       data.azurerm_key_vault.disk_vault.id
    key_type                        =       "RSA"
    key_size                        =       2048
    key_opts                        =       ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey",]
}

resource "azurerm_virtual_machine_extension" "linux-ade" {
    name                              =     "AzureDiskEncryption"
    virtual_machine_id                =     azurerm_linux_virtual_machine.example.id
    publisher                         =     "Microsoft.Azure.Security"
    type                              =     "AzureDiskEncryptionForLinux"
    type_handler_version              =     "1.1"
    auto_upgrade_minor_version        =     true

    settings = <<SETTINGS
    {
        "EncryptionOperation"         :     "EnableEncryption",
        "KeyVaultURL"                 :     "${data.azurerm_key_vault.disk_vault.vault_uri}",
        "KeyVaultResourceId"          :     "${data.azurerm_key_vault.disk_vault.id}",
        "KeyEncryptionKeyURL"         :     "${azurerm_key_vault_key.disk_key.id}",
        "KekVaultResourceId"          :     "${data.azurerm_key_vault.disk_vault.id}",
        "KeyEncryptionAlgorithm"      :     "RSA-OAEP",
        "VolumeType"                  :     "All"
    }
    SETTINGS

    depends_on                        =     [azurerm_linux_virtual_machine.example]
}
