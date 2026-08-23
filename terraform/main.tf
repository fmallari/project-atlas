locals {
  project_name = "Project Atlas"
}

output "project_name" {
  value = local.project_name
}

resource "aws_instance" "project_atlas" {
  ami           = "ami-0e5497a77ef21b5ac"
  instance_type = "t3.micro"

  key_name  = "cloud-roadmap"
  subnet_id = "subnet-0264c662e917db04d"

  vpc_security_group_ids = [
    "sg-02e05024074ab57ef"
  ]
  root_block_device {
    volume_size = 12
    volume_type = "gp3"
    iops        = 3000
    throughput  = 125
    encrypted   = false
  }
  tags = {
    Name = "project-atlas"
  }
}
