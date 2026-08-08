terraform {
  backend "s3" {
    bucket       = "project-atlas-tfstate-764553891483"
    key          = "project-atlas/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true
  }
}