output "terraform_dev_role" {
  value = aws_iam_role.terraform_dev_role.arn
}

# output "tfc_agent_token" {
#   value = data.external.get_tfc_agent_token.result["agent_token"]
# }
