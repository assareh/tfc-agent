output "public_ip" {
  value = azurerm_linux_virtual_machine.main.public_ip_address
}
