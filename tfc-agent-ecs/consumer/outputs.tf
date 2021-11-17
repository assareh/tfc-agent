output "caller" {
  value = data.aws_caller_identity.current.arn
}

output "instance_arn" {
  value = aws_instance.example.arn
}

output "public_dns" {
  value = aws_instance.example.public_dns
}
