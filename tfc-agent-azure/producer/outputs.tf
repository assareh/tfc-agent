# this is not matching
output "ip_address" {
  value = azurerm_container_group.tfc-agent.ip_address
}

output "principal_id" {
  value = azurerm_container_group.tfc-agent.identity[0].principal_id
}
