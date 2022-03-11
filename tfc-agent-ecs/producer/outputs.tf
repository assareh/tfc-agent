output "terraform_dev_role" {
  description = "Example IAM role created for terraform developer use in consumer workspace"
  value       = aws_iam_role.terraform_dev_role.arn
}

output "vpc_id" {
  description = "The AWS VPC ID, which will be needed for peering with an HVN"
  value       = aws_vpc.main.id
}

output "webhook_url" {
  description = "Webhook URL if using autoscaling through workspace notifications"
  value       = aws_api_gateway_deployment.webhook.invoke_url
}
