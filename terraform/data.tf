data "aws_caller_identity" "current" {}

data "aws_instance" "project_atlas" {
  filter {
    name   = "tag:Name"
    values = ["project-atlas"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}