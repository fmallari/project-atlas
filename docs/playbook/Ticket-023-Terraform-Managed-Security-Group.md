# Ticket 023 — Terraform-Managed Security Group

## Objective

Bring the existing Project Atlas EC2 security group under Terraform management without recreating or modifying the live security rules.

This ticket continues the brownfield Infrastructure-as-Code migration pattern established in earlier Terraform tickets:

```text
Discover → Model → Import → Reconcile Drift → Validate Zero-Change Plan
```

## Existing Security Group

The Project Atlas EC2 instance uses the existing security group:

- **Group ID:** `sg-02e05024074ab57ef`
- **Group Name:** `launch-wizard-1`
- **VPC:** `vpc-05769afea92a643a7`

## Existing Rule Inventory

### Inbound Rules

| Port | Protocol | Source |
| --- | --- | --- |
| 80 | TCP | `0.0.0.0/0` |
| 22 | TCP | `172.116.28.173/32` |
| 5000 | TCP | `172.116.28.173/32` |
| 443 | TCP | `0.0.0.0/0` |

### Outbound Rules

| Protocol | Destination |
| --- | --- |
| All | `0.0.0.0/0` |

## Architecture

```text
Internet
   |
   | 80 / 443
   v
Project Atlas Security Group
   |
   | 22 / 5000 restricted to admin IP
   v
EC2 Instance
   |
   v
Nginx → Gunicorn → Flask
```

## Implementation

### 1. Discover the Existing Security Group

```bash
AWS_PAGER="" aws ec2 describe-security-groups \
  --region us-east-2 \
  --group-ids sg-02e05024074ab57ef \
  --query "SecurityGroups[0].{GroupId:GroupId,GroupName:GroupName,Description:Description,VpcId:VpcId,Inbound:IpPermissions,Outbound:IpPermissionsEgress}" \
  --output json
```

### 2. Inventory Inbound Rules

```bash
AWS_PAGER="" aws ec2 describe-security-groups \
  --region us-east-2 \
  --group-ids sg-02e05024074ab57ef \
  --query "SecurityGroups[0].IpPermissions[].{Protocol:IpProtocol,FromPort:FromPort,ToPort:ToPort,IPv4:IpRanges[].CidrIp,IPv6:Ipv6Ranges[].CidrIpv6}" \
  --output table
```

### 3. Inventory Outbound Rules

```bash
AWS_PAGER="" aws ec2 describe-security-groups \
  --region us-east-2 \
  --group-ids sg-02e05024074ab57ef \
  --query "SecurityGroups[0].IpPermissionsEgress[].{Protocol:IpProtocol,FromPort:FromPort,ToPort:ToPort,IPv4:IpRanges[].CidrIp,IPv6:Ipv6Ranges[].CidrIpv6}" \
  --output json
```

### 4. Define the Security Group in Terraform

Created `terraform/security.tf`:

```hcl
resource "aws_security_group" "project_atlas" {
  name        = "launch-wizard-1"
  description = "launch-wizard-1 created 2026-07-11T04:37:10.067Z"
  vpc_id      = "vpc-05769afea92a643a7"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.116.28.173/32"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["172.116.28.173/32"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### 5. Validate the Terraform Configuration

```bash
terraform fmt
terraform validate
```

Result:

```text
Success! The configuration is valid.
```

### 6. Import the Existing Security Group

```bash
terraform import aws_security_group.project_atlas sg-02e05024074ab57ef
```

Result:

```text
Import successful!
```

### 7. Verify Terraform State

```bash
terraform state list
```

Terraform state now includes:

```text
aws_security_group.project_atlas
```

### 8. Reconcile Drift

The first post-import `terraform plan` showed an in-place update because the Terraform configuration added ingress rule descriptions that were not present in the live AWS security group.

The configuration was adjusted to match the actual AWS resource by removing those rule descriptions.

No infrastructure changes were applied during this reconciliation.

### 9. Validate Zero Drift

```bash
terraform fmt
terraform validate
terraform plan
```

Final result:

```text
No changes. Your infrastructure matches the configuration.
```

## Validation

Ticket 023 was successful when:

- Existing security group configuration was discovered before import
- Inbound and outbound rules were inventoried
- Terraform configuration passed validation
- Existing security group was imported successfully
- `terraform state list` contained `aws_security_group.project_atlas`
- Initial drift was identified and reconciled in code
- Final `terraform plan` returned **No changes**
- No security group replacement was proposed
- No production rules were intentionally modified

## Evidence

Recommended screenshots:

1. `screenshots/Ticket-023/existing-security-group-discovery.png`
2. `screenshots/Ticket-023/security-group-rule-inventory.png`
3. `screenshots/Ticket-023/security-group-terraform-config.png`
4. `screenshots/Ticket-023/security-group-import-success.png`
5. `screenshots/Ticket-023/security-group-state-list.png`
6. `screenshots/Ticket-023/security-group-no-change-plan.png`

## Key Takeaways

- Existing AWS security groups can be adopted into Terraform without recreating them.
- Discovery should happen before writing Terraform for production resources.
- `terraform import` associates an existing AWS resource with a Terraform resource address.
- A successful import does not guarantee zero drift.
- `terraform plan` is essential after import to identify configuration differences.
- Cosmetic differences, such as rule descriptions, can still produce a Terraform update plan.
- Brownfield IaC migration is safest when Terraform configuration is first made to match reality.
- A final **No changes** plan confirms Terraform and AWS are aligned.

## Cloud/SRE Relevance

This ticket demonstrates a common platform-engineering workflow: adopting manually configured network-security infrastructure into Infrastructure as Code.

Skills demonstrated:

- AWS security group inspection
- Network rule inventory
- Terraform resource modeling
- Terraform import
- Terraform state verification
- Drift detection and reconciliation
- Production change safety
- Infrastructure documentation

## Result

**Ticket 023 completed successfully.**

The existing Project Atlas security group was imported into Terraform state, its live rules were represented in HCL, drift was reconciled, and the final Terraform plan returned:

```text
No changes. Your infrastructure matches the configuration.
```

Project Atlas now has both its EC2 instance and its security group under Terraform management without recreating the live infrastructure.

