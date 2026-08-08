# Ticket 022 — Remote Terraform State with S3

## Objective

Migrate Project Atlas Terraform state from the local workstation to a secure, versioned Amazon S3 backend so Terraform state is stored remotely and managed more reliably.

This ticket extends the Terraform workflow from local state management to a production-style remote backend while preserving the existing Project Atlas EC2 resource already tracked by Terraform.

## Architecture

```text
Terraform on Mac
      |
      | terraform init / plan / state
      v
Private Amazon S3 Backend
      |
      | project-atlas/terraform.tfstate
      v
Terraform State
      |
      v
Project Atlas EC2
```

## Backend Design

The remote backend uses a dedicated S3 bucket in `us-east-2`.

Key controls:

- Dedicated Terraform state bucket
- S3 versioning enabled
- S3 Block Public Access enabled
- Server-side encryption
- Terraform state stored under a dedicated key prefix
- Native Terraform S3 lock-file support configured

## Implementation

### 1. Define the Terraform State Bucket Name

```bash
export TF_STATE_BUCKET="project-atlas-tfstate-$(aws sts get-caller-identity --query Account --output text)"
echo "$TF_STATE_BUCKET"
```

### 2. Create the S3 Bucket

```bash
aws s3api create-bucket \
  --bucket "$TF_STATE_BUCKET" \
  --region us-east-2 \
  --create-bucket-configuration LocationConstraint=us-east-2
```

### 3. Enable Bucket Versioning

```bash
aws s3api put-bucket-versioning \
  --bucket "$TF_STATE_BUCKET" \
  --versioning-configuration Status=Enabled
```

### 4. Block Public Access

```bash
aws s3api put-public-access-block \
  --bucket "$TF_STATE_BUCKET" \
  --public-access-block-configuration \
'{
  "BlockPublicAcls": true,
  "IgnorePublicAcls": true,
  "BlockPublicPolicy": true,
  "RestrictPublicBuckets": true
}'
```

### 5. Configure the Terraform S3 Backend

Create `terraform/backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket       = "project-atlas-tfstate-<AWS_ACCOUNT_ID>"
    key          = "project-atlas/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true
  }
}
```

### 6. Migrate Existing Local State

```bash
terraform init -migrate-state
```

Terraform copied the existing state into the S3 backend.

### 7. Verify Terraform State

```bash
terraform state list
```

Expected state included:

```text
data.aws_caller_identity.current
data.aws_instance.project_atlas
aws_instance.project_atlas
```

### 8. Validate the Infrastructure Plan

```bash
terraform plan
```

Result:

```text
No changes. Your infrastructure matches the configuration.
```

### 9. Verify the Remote State Object

```bash
aws s3 ls "s3://$TF_STATE_BUCKET/project-atlas/" --recursive
```

Result:

```text
project-atlas/terraform.tfstate
```

## Validation

Ticket 022 was successful when:

- Dedicated S3 state bucket existed
- Bucket versioning was enabled
- Public access was blocked
- Terraform S3 backend was configured
- Existing local state migrated successfully
- `terraform state list` retained `aws_instance.project_atlas`
- `terraform plan` returned **No changes**
- Remote `project-atlas/terraform.tfstate` object was confirmed in S3
- Running Project Atlas EC2 instance remained unaffected

## Evidence

Recommended screenshots:

1. `screenshots/Ticket-022/01-state-bucket-created.png`
2. `screenshots/Ticket-022/02-versioning-enabled.png`
3. `screenshots/Ticket-022/public-access-blocked.png`
4. `screenshots/Ticket-022/backend-configuration.png`
5. `screenshots/Ticket-022/state-migration-success.png`
6. `screenshots/Ticket-022/remote-state-in-s3.png`
7. `screenshots/Ticket-022/remote-state-no-change-plan.png`

## Key Takeaways

- Terraform state is critical infrastructure metadata and should not depend on one workstation.
- An S3 backend provides durable remote storage for Terraform state.
- S3 versioning improves recoverability.
- Public access should be blocked for Terraform state buckets.
- Backend migration can move existing Terraform state without recreating infrastructure.
- `terraform state list` verifies that managed resources remain associated with Terraform after migration.
- A post-migration `terraform plan` returning **No changes** is a strong safety validation.

## Cloud/SRE Relevance

This ticket demonstrates a foundational platform-engineering practice: separating Terraform configuration from Terraform state.

Skills demonstrated:

- Terraform backend configuration
- Terraform state migration
- Amazon S3 administration
- State durability and recovery
- Infrastructure security controls
- Production-change validation
- Terraform state inspection
- Remote infrastructure management

## Result

**Ticket 022 completed successfully.**

Project Atlas Terraform state was migrated from the local workstation into a private, versioned S3 backend.

Terraform retained management of the existing Project Atlas EC2 instance, the remote state object was verified in S3, and the final Terraform plan returned:

```text
No changes. Your infrastructure matches the configuration.
```

The migration introduced remote Terraform state without disrupting the running Project Atlas environment.

