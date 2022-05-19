output "keyvault_name" {
  value = azurerm_key_vault.example_keyvault.name
}

output "private_key" {
  value = tls_private_key.example_ssh.private_key_openssh
  sensitive = true
}

output "public_key" {
  value = tls_private_key.example_ssh.public_key_openssh
}
