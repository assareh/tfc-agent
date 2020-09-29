output "terraform_dev_role" {
  value = aws_iam_role.terraform_dev_role.arn
}

# output "tfc_agent_token" {
#   value = jsondecode(module.tfc_agent_token.stdout)["agent_token"]
# }
