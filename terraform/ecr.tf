resource "aws_ecr_repository" "project_atlas" {
  name                 = "project-atlas"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = "project-atlas"
    Project = "ProjectAtlas"
  }
}