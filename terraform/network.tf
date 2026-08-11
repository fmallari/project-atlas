resource "aws_vpc" "project_atlas" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "project_atlas" {
  vpc_id                  = aws_vpc.project_atlas.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zone
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