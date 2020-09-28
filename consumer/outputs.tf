output "caller" {
  value = data.aws_caller_identity.current.arn
}

output "instance_arn" {
  value = aws_instance.vault.arn
}
