resource "aws_vpc" "project_atlas" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "project_atlas" {
  vpc_id                  = aws_vpc.project_atlas.id
  cidr_block              = "172.31.32.0/20"
  availability_zone       = "us-east-2c"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "project_atlas" {
  vpc_id = aws_vpc.project_atlas.id
}

resource "aws_route_table" "project_atlas" {
  vpc_id = aws_vpc.project_atlas.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project_atlas.id
  }
}