# Subnet id
output "public_subnet_id" {
  value       = aws_subnet.public_subnet.id
  description = "The public subnet id"
}

# Security group id
output "security_group_id" {
  value       = aws_security_group.allow_http.id
  description = "The security group id"
}
