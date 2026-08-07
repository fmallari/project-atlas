# Ticket 021 --- Import Existing EC2 Infrastructure into Terraform

## Objective

Safely bring the existing **Project Atlas EC2 instance** under Terraform
state management without recreating, stopping, replacing, or otherwise
disrupting the running server.

This ticket demonstrates how an existing manually provisioned AWS
resource can be adopted into Infrastructure as Code (IaC).

## Existing Infrastructure

Before importing the instance, the existing EC2 configuration was
inspected with the AWS CLI.

  Attribute        Existing Value
  ---------------- ----------------------------
  Instance ID      `i-04d2e8e83c761e54c`
  AMI              `ami-0e5497a77ef21b5ac`
  Instance Type    `t3.micro`
  Key Pair         `cloud-roadmap`
  Subnet ID        `subnet-0264c662e917db04d`
  VPC ID           `vpc-05769afea92a643a7`
  Security Group   `sg-02e05024074ab57ef`
  Private IP       `172.31.40.32`
  Public IP        `3.139.73.189`
  Name Tag         `project-atlas`

## Architecture

``` text
Existing Project Atlas EC2 Instance
            |
            | inspect with AWS CLI
            v
Terraform aws_instance Resource
            |
            | terraform import
            v
Local Terraform State
            |
            | terraform plan
            v
Configuration vs. Live AWS Resource
            |
            v
         No Changes
```

## Implementation

### 1. Inspect the Existing EC2 Instance

The live instance was inspected before writing the Terraform resource
definition.

``` bash
aws ec2 describe-instances \
  --region us-east-2 \
  --instance-ids i-04d2e8e83c761e54c \
  --query "Reservations[0].Instances[0].{AMI:ImageId,InstanceType:InstanceType,KeyName:KeyName,SubnetId:SubnetId,VpcId:VpcId,SecurityGroups:SecurityGroups,PublicIP:PublicIpAddress,PrivateIP:PrivateIpAddress}" \
  --output table
```

This established the existing server configuration before Terraform was
allowed to manage it.

### 2. Define the Existing Instance as a Terraform Resource

The existing EC2 configuration was represented in `terraform/main.tf`:

``` hcl
resource "aws_instance" "project_atlas" {
  ami           = "ami-0e5497a77ef21b5ac"
  instance_type = "t3.micro"

  key_name  = "cloud-roadmap"
  subnet_id = "subnet-0264c662e917db04d"

  vpc_security_group_ids = [
    "sg-02e05024074ab57ef"
  ]

  tags = {
    Name = "project-atlas"
  }
}
```

At this stage, the resource block described the desired Terraform
configuration, but Terraform state did not yet associate it with the
existing AWS instance.

### 3. Format and Validate the Configuration

``` bash
terraform fmt
terraform validate
```

Validation result:

``` text
Success! The configuration is valid.
```

### 4. Safety Check Before Import

A Terraform plan before import showed:

``` text
# aws_instance.project_atlas will be created
```

This was an important safety signal. Because the existing EC2 instance
had not yet been imported into Terraform state, Terraform treated the
resource declaration as a request for a new instance.

**No apply was performed.**

This demonstrated the importance of reviewing `terraform plan` before
making infrastructure changes.

### 5. Import the Existing EC2 Instance

The existing instance was associated with the Terraform resource
address:

``` bash
terraform import aws_instance.project_atlas i-04d2e8e83c761e54c
```

Terraform returned:

``` text
Import successful!
```

No new EC2 instance was created as part of the import.

### 6. Verify Terraform State

The state was inspected with:

``` bash
terraform state list
```

The result included:

``` text
aws_instance.project_atlas
```

This confirmed that Terraform was now tracking the existing EC2 instance
as a managed resource.

### 7. Run the Post-Import Plan

A final safety check was performed:

``` bash
terraform plan
```

Result:

``` text
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration
and found no differences, so no changes are needed.
```

This confirmed that the Terraform resource definition matched the
running Project Atlas instance and that Terraform was not proposing a
replacement or unintended modification.

## Validation

Ticket 021 was considered successful when all of the following
conditions were met:

-   Existing EC2 configuration was inspected before import.
-   Terraform configuration passed `terraform validate`.
-   No `terraform apply` was performed while Terraform proposed creating
    a new instance.
-   `terraform import` completed successfully.
-   `terraform state list` contained `aws_instance.project_atlas`.
-   The post-import `terraform plan` returned **No changes**.
-   The existing Project Atlas EC2 instance remained running.
-   Terraform state files were excluded from Git tracking.

## State File Safety

Terraform created local state as part of managing the imported resource.

State files should not be committed to the public repository. Git status
was checked after the import, and Terraform state files did not appear
as tracked or untracked repository changes.

The repository only showed the intended Ticket 021 changes, including:

``` text
terraform/main.tf
screenshots/Ticket-021/
```

## Evidence

Recommended screenshots for this ticket:

1.  `screenshots/Ticket-021/01-existing-ec2-configuration.png`
    -   AWS CLI output showing the configuration of the existing Project
        Atlas EC2 instance.
2.  `screenshots/Ticket-021/02-import-and-no-change-plan.png`
    -   Successful `terraform import`.
    -   `terraform state list` showing `aws_instance.project_atlas`.
    -   Post-import `terraform plan` showing **No changes**.
3.  `screenshots/Ticket-021/03-git-status-state-excluded.png`
    -   Git status demonstrating that Terraform state is not being added
        to version control.

## Key Takeaways

-   Terraform can adopt infrastructure that already exists instead of
    requiring it to be rebuilt.
-   A Terraform resource declaration and Terraform state serve different
    purposes.
-   Before import, Terraform may interpret a resource block as
    infrastructure that needs to be created.
-   `terraform import` establishes the relationship between a Terraform
    resource address and an existing cloud resource.
-   `terraform state list` provides a direct way to verify that a
    resource is under Terraform management.
-   `terraform plan` is a critical safety mechanism when adopting
    existing production infrastructure.
-   A post-import **No changes** plan provides strong evidence that the
    Terraform configuration matches the existing resource.
-   Terraform state contains infrastructure-management information and
    should not be committed to a public Git repository.

## Cloud/SRE Relevance

This ticket models a common real-world cloud engineering scenario:
adopting manually provisioned or legacy infrastructure into
Infrastructure as Code without causing downtime.

The workflow demonstrates:

-   Existing infrastructure discovery
-   AWS CLI investigation
-   Terraform resource modeling
-   Infrastructure state management
-   Safe infrastructure adoption
-   Change-plan review
-   Production-risk awareness
-   Version-control hygiene

Rather than rebuilding a working production server, Project Atlas now
demonstrates a controlled migration path from manually provisioned AWS
infrastructure toward Terraform-managed infrastructure.

## Result

**Ticket 021 completed successfully.**

The existing Project Atlas EC2 instance was imported into Terraform
state, Terraform recognized the instance as
`aws_instance.project_atlas`, and the final execution plan reported:

``` text
No changes. Your infrastructure matches the configuration.
```

The running EC2 instance was therefore brought under Terraform
management without requiring replacement or an intentional
infrastructure change.

