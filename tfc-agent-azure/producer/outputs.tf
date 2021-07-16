output "agent_ip" {
  value = azurerm_container_group.tfc-agent.ip_address
}

output "function_app_name" {
  value       = azurerm_function_app.function_app.name
  description = "Deployed function app name"
}

output "principal_id" {
  value = azurerm_container_group.tfc-agent.identity[0].principal_id
}

output "webhook_url" {
  value = "https://${azurerm_function_app.function_app.default_hostname}/api/webhook"
}
