output "Workspace" {
  value = var.workspacename
}
output "ws-id" {
  value = var.identifier != "" ? tfe_workspace.ws-template[0].id : tfe_workspace.ws-novcs[0].id
}