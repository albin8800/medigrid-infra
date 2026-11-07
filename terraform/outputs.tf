output "vpc_id" {
  description = "The ID of the MediGrid VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "The CIDR block range of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets (Internet-facing)"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets (Databases & Internal Services)"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}
