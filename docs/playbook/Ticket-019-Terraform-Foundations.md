# Ticket 019 - Terraform Foundations

## Objective

Learn Terraform fundamentals by creating the initial Infrastructure-as-Code project structure that will later be used to manage Project Atlas AWS resources.

## Architecture

[Architecture diagram]

## Technologies

- Terraform
- AWS Provider
- VS Code
- Git

## Files Created

- versions.tf
- provider.tf
- variables.tf
- outputs.tf
- main.tf

## Implementation

### Step 1
Install Terraform

### Step 2
Initialize Terraform project

### Step 3
Configure AWS provider

### Step 4
Validate configuration

### Step 5
Run terraform plan

## Validation

terraform init ✅

terraform validate ✅

terraform plan ✅

## Lessons Learned

- Provider plugins are downloaded locally into `.terraform/`
- `.terraform/` should never be committed
- `.terraform.lock.hcl` should be committed
- Terraform initialization creates a reproducible development environment

## Incident

### GitHub rejected push because Terraform provider exceeded 100 MB

Root Cause:
`.terraform/` directory was accidentally committed.

Resolution:
- Added `.terraform/` to `.gitignore`
- Removed provider binaries from Git tracking
- Preserved `.terraform.lock.hcl`
- Amended commit
- Successfully pushed repository

##Screenshots

01-terraform-project-structure.png
02-terraform-init-success.png
03-terrarform-plan-success.png

## Latest Infrastructure Milestones

### ✅ Ticket 017
CloudWatch Metric Filters

### ✅ Ticket 018
Self-Healing Infrastructure
- CloudWatch Alarm
- SNS
- EventBridge
- Systems Manager Run Command
- Automatic Gunicorn Restart

### ✅ Ticket 019
Terraform Foundations
- Infrastructure as Code
- AWS Provider
- Version Pinning
- Variable Management
- Terraform Project Structure
