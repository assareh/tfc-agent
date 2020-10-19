output "terraform_dev_role" {
  value = aws_iam_role.terraform_dev_role.arn
}

output "webhook_url" {
  value = aws_api_gateway_deployment.webhook.invoke_url
}
