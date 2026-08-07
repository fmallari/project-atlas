output "aws_region" {
  value = var.aws_region
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "user_id" {
  value = data.aws_caller_identity.current.user_id
}

output "project_atlas_instance_id" {
  value = data.aws_instance.project_atlas.id
}

output "project_atlas_instance_type" {
  value = data.aws_instance.project_atlas.instance_type
}

output "project_atlas_private_ip" {
  value = data.aws_instance.project_atlas.private_ip
}

output "project_atlas_public_ip" {
  value = data.aws_instance.project_atlas.public_ip
}