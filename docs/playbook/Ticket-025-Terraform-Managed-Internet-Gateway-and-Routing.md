# Ticket 025 — Terraform-Managed Internet Gateway and Route Table

## Objective
Bring the existing Project Atlas Internet Gateway and main route table under Terraform management without recreating or disrupting the live network.

## Architecture
```text
Internet
  ↓
Internet Gateway: igw-0e077efe0680ccd07
  ↓
Main Route Table: rtb-0a44fb28a69774b4b
  ├─ 172.31.0.0/16 → local
  └─ 0.0.0.0/0 → Internet Gateway
  ↓
Subnet: subnet-0264c662e917db04d
  ↓
Security Group
  ↓
EC2 → Nginx → Gunicorn → Flask
```

## Existing Resources
- VPC: `vpc-05769afea92a643a7`
- Internet Gateway: `igw-0e077efe0680ccd07`
- Main Route Table: `rtb-0a44fb28a69774b4b`
- Subnet: `subnet-0264c662e917db04d`

## Discovery

### Internet Gateway
```bash
AWS_PAGER="" aws ec2 describe-internet-gateways \
  --region us-east-2 \
  --filters "Name=attachment.vpc-id,Values=vpc-05769afea92a643a7" \
  --query "InternetGateways[].{InternetGatewayId:InternetGatewayId,Attachments:Attachments,Tags:Tags}" \
  --output table
```

### Check Explicit Subnet Association
```bash
AWS_PAGER="" aws ec2 describe-route-tables \
  --region us-east-2 \
  --filters "Name=association.subnet-id,Values=subnet-0264c662e917db04d" \
  --query "RouteTables[].{RouteTableId:RouteTableId,VpcId:VpcId,Routes:Routes,Associations:Associations}" \
  --output json
```

Result:
```text
[]
```

The subnet had no explicit route-table association and therefore inherited the VPC main route table.

### Main Route Table
```bash
AWS_PAGER="" aws ec2 describe-route-tables \
  --region us-east-2 \
  --filters \
    "Name=vpc-id,Values=vpc-05769afea92a643a7" \
    "Name=association.main,Values=true" \
  --query "RouteTables[].{RouteTableId:RouteTableId,VpcId:VpcId,Routes:Routes,Associations:Associations}" \
  --output json
```

Confirmed:
- `172.31.0.0/16 → local`
- `0.0.0.0/0 → igw-0e077efe0680ccd07`
- Main association: `true`

## Terraform Configuration

Added to `terraform/network.tf`:

```hcl
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
```

The AWS-managed local VPC route was not recreated manually.

## Internet Gateway Import

Before import, `terraform plan` showed Terraform would create a new Internet Gateway. No apply was performed.

```bash
terraform import aws_internet_gateway.project_atlas igw-0e077efe0680ccd07
```

## Route Table Import Lesson

An initial route-table import failed because the Terraform resource block did not yet exist:

```text
Error: resource address "aws_route_table.project_atlas" does not exist in the configuration.
```

After creating the resource block:

```bash
terraform fmt
terraform validate
terraform plan
```

Validation succeeded.

The existing route table was then imported:

```bash
terraform import aws_route_table.project_atlas rtb-0a44fb28a69774b4b
```

Result:
```text
Import successful!
```

## State Verification

```bash
terraform state list
```

State included:
```text
data.aws_caller_identity.current
data.aws_instance.project_atlas
aws_instance.project_atlas
aws_internet_gateway.project_atlas
aws_route_table.project_atlas
aws_security_group.project_atlas
aws_subnet.project_atlas
aws_vpc.project_atlas
```

## Final Validation

```bash
terraform plan
```

Result:
```text
No changes. Your infrastructure matches the configuration.
```

## Evidence
1. `screenshots/Ticket-025/existing-internet-gateway.png`
2. `screenshots/Ticket-025/igw-pre-import-plan.png`
3. `screenshots/Ticket-025/igw-import-success.png`
4. `screenshots/Ticket-025/existing-main-route-table.png`
5. `screenshots/Ticket-025/import-before-resource-error.png`
6. `screenshots/Ticket-025/route-table-import-success.png`
7. `screenshots/Ticket-025/network-routing-no-change-plan.png`

## Key Takeaways
- A public EC2 instance depends on more than a public IP; it needs a valid route through a route table and Internet Gateway.
- A subnet without an explicit route-table association inherits the VPC main route table.
- Terraform import requires a matching resource block in configuration.
- A pre-import plan is a useful safety signal because it shows what Terraform would otherwise create.
- Existing network infrastructure can be adopted into Terraform without recreation.
- A final zero-change plan confirms configuration, Terraform state, and live AWS infrastructure are aligned.

## Cloud/SRE Relevance
Skills demonstrated:
- AWS Internet Gateway discovery
- Route table inspection
- Main versus explicit associations
- Default-route analysis
- Terraform network resource modeling
- Terraform import
- State verification
- Drift validation
- Production-safe infrastructure adoption

## Result
**Ticket 025 completed successfully.**

Project Atlas now has its VPC, subnet, security group, Internet Gateway, main route table, and EC2 instance represented in Terraform.

Final validation:
```text
No changes. Your infrastructure matches the configuration.
```

