// Workspace Data
data "terraform_remote_state" "presto_projects_ws_aws_iam" {
  backend = "atlas"
  config = {
    address = "https://app.terraform.io"
    name    = "presto-projects/ws_aws_iam"
  }
}
# data.terraform_remote_state.presto_projects_ws_aws_iam.outputs.serviceA_agentpool_id
# data.terraform_remote_state.presto_projects_ws_aws_iam.outputs.serviceB_agentpool_id