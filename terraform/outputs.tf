output "aws_region" {
  description = "AWS region for Project Atlas"
  value       = var.aws_region
}

output "project_atlas_instance_id" {
  description = "EC2 instance ID for Project Atlas"
  value       = aws_instance.project_atlas.id
}

output "project_atlas_public_ip" {
  description = "Public IPv4 address of the Project Atlas EC2 instance"
  value       = aws_instance.project_atlas.public_ip
}

output "project_atlas_private_ip" {
  description = "Private IPv4 address of the Project Atlas EC2 instance"
  value       = aws_instance.project_atlas.private_ip
}

output "project_atlas_vpc_id" {
  description = "VPC ID used by Project Atlas"
  value       = aws_vpc.project_atlas.id
}

output "project_atlas_subnet_id" {
  description = "Subnet ID used by Project Atlas"
  value       = aws_subnet.project_atlas.id
}

output "project_atlas_security_group_id" {
  description = "Security group ID used by Project Atlas"
  value       = aws_security_group.project_atlas.id
}

output "project_atlas_internet_gateway_id" {
  description = "Internet Gateway ID used by Project Atlas"
  value       = aws_internet_gateway.project_atlas.id
}

output "project_atlas_route_table_id" {
  description = "Route table ID used by Project Atlas"
  value       = aws_route_table.project_atlas.id
}

output "project_atlas_ecr_repository_url" {
  description = "ECR repository URL for Project Atlas"
  value       = aws_ecr_repository.project_atlas.repository_url
}