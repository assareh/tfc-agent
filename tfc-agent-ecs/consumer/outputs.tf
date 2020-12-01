output "caller" {
  value       = data.aws_caller_identity.current.arn
  sensitive   = true
}

output "instance_arn" {
  value = aws_instance.vault.arn
}
