// Workspace Data
data "terraform_remote_state" "presto_projects_ws_aws_iam" {
  backend = "atlas"
  config = {
    address = "https://app.terraform.io"
    name    = "presto-projects/ws_aws_iam"
  }
}
# data.terraform_remote_state.presto_projects_ws_aws_iam.outputs.agent_arn
# data.terraform_remote_state.presto_projects_ws_aws_iam.outputs.ecs_init_serviceB_arn
# data.terraform_remote_state.presto_projects_ws_aws_iam.outputs.aws_ssm_param_serviceB_tfc_arn