output "caller" {
  value       = data.aws_caller_identity.current.arn
  sensitive   = true
}

output "instance_id" {
  value = aws_instance.vault.id
}
