# Ticket 020 --- Discover Existing AWS Infrastructure with Terraform Data Sources

## Objective

Extend the Project Atlas Terraform foundation so Terraform can
authenticate to AWS and safely discover existing infrastructure without
creating, modifying, or destroying production resources.

This ticket demonstrates how Terraform data sources can be used to
inspect infrastructure that already exists in AWS before bringing it
under Infrastructure as Code management.

## Background

Project Atlas was originally provisioned manually in AWS. Before
importing existing resources into Terraform state, Terraform first needs
to prove that it can:

-   Authenticate successfully to the correct AWS account.
-   Query AWS resources in the correct region.
-   Discover the existing `project-atlas` EC2 instance.
-   Expose useful infrastructure attributes through Terraform outputs.
-   Produce a plan without making changes to the running server.

This provides a safe bridge between manually provisioned infrastructure
and Terraform-managed infrastructure.

## Architecture

``` text
Local Mac
   |
   | AWS CLI credentials
   v
Terraform AWS Provider
   |
   +--> aws_caller_identity data source
   |       |
   |       +--> Account ID
   |       +--> Caller ARN
   |       +--> User ID
   |
   +--> aws_instance data source
           |
           +--> Existing project-atlas EC2
                   |
                   +--> Instance ID
                   +--> Instance type
                   +--> Private IP
                   +--> Public IP
```

Terraform is operating in **read-only discovery mode** for the existing
EC2 instance during this ticket. The instance is not yet represented as
a Terraform-managed resource.

## Implementation

### 1. Verify AWS CLI authentication

Confirmed the local workstation was authenticated to AWS:

``` bash
aws sts get-caller-identity
```

The command returned the AWS account, IAM user ID, and caller ARN,
confirming that the local AWS CLI credentials were valid.

### 2. Confirm the existing Project Atlas EC2 instance

Queried EC2 in `us-east-2` and confirmed the running instance tagged
`project-atlas`:

``` bash
aws ec2 describe-instances \
  --region us-east-2 \
  --filters "Name=tag:Name,Values=project-atlas" \
  --query "Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name,Type:InstanceType,PrivateIP:PrivateIpAddress,PublicIP:PublicIpAddress}" \
  --output table
```

The query identified the existing running Project Atlas EC2 instance and
confirmed its current infrastructure attributes.

### 3. Add AWS caller identity data source

Created `terraform/data.tf` and added:

``` hcl
data "aws_caller_identity" "current" {}
```

This allows Terraform to retrieve metadata about the AWS identity being
used by the provider.

### 4. Discover the existing EC2 instance

Extended the Terraform data configuration to locate the existing Project
Atlas EC2 instance using its AWS tags.

``` hcl
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
```

This is intentionally a **data source**, not an `aws_instance` resource.
Terraform therefore reads the existing instance rather than attempting
to create or manage it.

### 5. Add Terraform outputs

Updated `outputs.tf` so the Terraform plan exposes useful AWS and EC2
information, including:

-   AWS region
-   AWS account ID
-   Caller ARN
-   IAM user ID
-   Project Atlas instance ID
-   Instance type
-   Private IP address
-   Public IP address
-   Project name

Example:

``` hcl
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
```

## Validation

Formatted the Terraform configuration:

``` bash
terraform fmt
```

Validated the configuration:

``` bash
terraform validate
```

Result:

``` text
Success! The configuration is valid.
```

Then generated a Terraform plan:

``` bash
terraform plan
```

Terraform successfully read both data sources:

``` text
data.aws_caller_identity.current: Read complete
data.aws_instance.project_atlas: Read complete
```

The resulting plan exposed the expected infrastructure values while
reporting only output changes.

Most importantly, Terraform reported that these values could be saved to
state:

``` text
without changing any real infrastructure.
```

No EC2 resources were created, replaced, stopped, or destroyed.

## Evidence

Ticket evidence captures:

1.  Terraform `data.tf` configuration with the AWS caller identity data
    source.
2.  Terraform `outputs.tf` configuration exposing AWS identity
    information.
3.  Initial `terraform plan` successfully retrieving AWS account
    metadata.
4.  AWS CLI discovery of the existing `project-atlas` EC2 instance in
    `us-east-2`.
5.  Final `terraform fmt`, `terraform validate`, and `terraform plan`
    showing successful discovery of the existing EC2 instance and its
    attributes.

## Key Takeaways

-   Terraform **data sources** read infrastructure that already exists;
    they do not automatically take ownership of it.
-   AWS CLI commands are useful for independently validating the
    infrastructure Terraform is expected to discover.
-   Tag-based discovery provides a practical way to locate existing AWS
    resources.
-   `terraform validate` confirms configuration syntax and internal
    consistency before planning.
-   `terraform plan` should always be reviewed carefully when adopting
    Terraform around existing production infrastructure.
-   Existing infrastructure should be discovered and understood before
    it is imported into Terraform state.

## SRE / Cloud Engineering Relevance

This ticket models a common brownfield Infrastructure as Code workflow.
Production environments frequently contain resources that predate
Terraform. Rather than immediately recreating those resources, an
engineer should first inventory and inspect them, confirm provider
access, understand their current attributes, and establish a safe path
toward IaC management.

The workflow demonstrated here supports:

-   Infrastructure discovery
-   AWS IAM/provider validation
-   Terraform data sources
-   Brownfield IaC adoption
-   Change-risk reduction
-   Production-safe Terraform planning

## Result

**Ticket 020 completed successfully.**

Terraform can now authenticate to AWS and discover the existing Project
Atlas EC2 infrastructure without modifying the running environment. This
establishes the prerequisite for the next phase: safely importing
existing AWS infrastructure into Terraform state.

