variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-2"
}

variable "availability_zone" {
  description = "Availability zone for the Project Atlas subnet"
  type        = string
  default     = "us-east-2c"
}

variable "vpc_cidr" {
  description = "CIDR block for the Project Atlas VPC"
  type        = string
  default     = "172.31.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the Project Atlas subnet"
  type        = string
  default     = "172.31.32.0/20"
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to access Project Atlas over SSH"
  type        = string
  default     = "76.174.168.219/32"
}