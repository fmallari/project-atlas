### Ticket 030 — GitHub OIDC and Automated ECR Publishing

Objective

Extend the Project Atlas GitHub Actions CI pipeline so validated Docker images can be published automatically to Amazon ECR.

The goal is to authenticate GitHub Actions to AWS using OpenID Connect (OIDC) and temporary AWS credentials rather than storing long-lived AWS access keys in GitHub.

This ticket builds directly on:

* Ticket 027 — Docker containerization
* Ticket 028 — Amazon ECR
* Ticket 029 — GitHub Actions CI

⸻

## Architecture

Developer
    |
    | git push
    v
GitHub
    |
    v
GitHub Actions
    |
    +--> Automated Tests
    |
    +--> Docker Build
    |
    +--> GitHub OIDC Token
    |
    v
AWS IAM Role
    |
    +--> Temporary Credentials
    |
    v
Amazon ECR
    |
    v
Versioned Container Image

The intended delivery workflow is:

Source Code
    ↓
pytest
    ↓
Docker Build
    ↓
OIDC Authentication
    ↓
Assume AWS IAM Role
    ↓
ECR Login
    ↓
Tag Image with Git Commit SHA
    ↓
Push Image to ECR

⸻

## Why OIDC

Rather than storing credentials such as:

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY

inside GitHub Secrets, Project Atlas uses GitHub Actions OIDC authentication.

GitHub Actions requests an identity token and exchanges it for temporary AWS credentials through AWS Security Token Service.

GitHub Actions
      ↓
OIDC Token
      ↓
AWS IAM Trust Policy
      ↓
AssumeRoleWithWebIdentity
      ↓
Temporary AWS Credentials

This reduces dependency on long-lived credentials and supports a more secure CI/CD authentication model.

⸻

Terraform Implementation

Created:

terraform/github-actions.tf

Terraform provisions three IAM-related resources:

aws_iam_openid_connect_provider.github_actions
aws_iam_role.github_actions
aws_iam_role_policy.github_actions_ecr

GitHub OIDC Provider

The AWS IAM OIDC provider trusts:

https://token.actions.githubusercontent.com

with the AWS STS audience:

sts.amazonaws.com

⸻

## GitHub Actions IAM Role

Created an IAM role:

project-atlas-github-actions

The trust policy is restricted to the Project Atlas repository and the main branch:

repo:fmallari/project-atlas:ref:refs/heads/main

This prevents unrelated GitHub repositories or branches from assuming the Project Atlas CI/CD role.

⸻

## Least-Privilege ECR Policy

Created the inline policy:

project-atlas-ecr-push

The policy grants GitHub Actions the permissions required to authenticate with ECR and publish container image layers.

Authentication requires:

ecr:GetAuthorizationToken

Image operations are scoped to the Project Atlas ECR repository.

The allowed image operations include:

ecr:BatchCheckLayerAvailability
ecr:GetDownloadUrlForLayer
ecr:BatchGetImage
ecr:InitiateLayerUpload
ecr:UploadLayerPart
ecr:CompleteLayerUpload
ecr:PutImage

This follows a least-privilege model by restricting image publishing access to the Project Atlas repository rather than all ECR repositories.

⸻

## Terraform Validation

The configuration was validated using:

terraform fmt
terraform validate
terraform plan

Terraform returned:

Success! The configuration is valid.

The execution plan showed:

Plan: 3 to add, 0 to change, 0 to destroy.

The changes were then applied:

terraform apply

Result:

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

No existing Project Atlas infrastructure was modified or destroyed.

⸻

## AWS Verification

The GitHub Actions role was verified through the AWS CLI:

aws iam get-role \
  --role-name project-atlas-github-actions \
  --query 'Role.[RoleName,Arn]' \
  --output table

AWS returned the expected role:

project-atlas-github-actions

The ECR push policy was also verified:

aws iam list-role-policies \
  --role-name project-atlas-github-actions \
  --output table

AWS returned:

project-atlas-ecr-push

⸻

## GitHub Actions Workflow Changes

The existing workflow:

.github/workflows/ci.yml

was extended with OIDC permissions:

permissions:
  contents: read
  id-token: write

The workflow also defines the Project Atlas AWS environment:

env:
  AWS_REGION: us-east-2
  ECR_REPOSITORY: project-atlas

⸻

## AWS Authentication

The pipeline configures AWS credentials by assuming the Terraform-managed IAM role:

- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v5
  with:
    role-to-assume: arn:aws:iam::764553891483:role/project-atlas-github-actions
    aws-region: ${{ env.AWS_REGION }}

No long-lived AWS access key or secret key is stored in the workflow.

⸻

## Amazon ECR Login

After obtaining temporary AWS credentials, GitHub Actions authenticates Docker with Amazon ECR:

- name: Login to Amazon ECR
  id: login-ecr
  uses: aws-actions/amazon-ecr-login@v2

⸻

## Commit-Based Image Versioning

Docker images are tagged using the Git commit SHA:

IMAGE_TAG: ${{ github.sha }}

The image publishing step is:

- name: Tag and push image to ECR
  env:
    ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
    IMAGE_TAG: ${{ github.sha }}
  run: |
    docker tag project-atlas:${{ github.sha }} $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
    docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG

This establishes traceability between source code and container artifacts:

Git Commit
    ↓
GitHub Actions
    ↓
Docker Image
    ↓
ECR Tag = Commit SHA

⸻

## Current Validation Status

The AWS OIDC provider, IAM role, and ECR permissions have been successfully provisioned and verified.

The GitHub Actions workflow has also been updated with:

* OIDC permissions
* AWS role assumption
* ECR authentication
* Commit-SHA image tagging
* ECR publishing commands

However, the most recent GitHub Actions runs are currently reporting a failure after the Ticket 030 workflow changes.

Earlier Ticket 029 CI runs completed successfully, while failures began after introducing the AWS/ECR publishing stages.

The first failing workflow step still needs to be inspected before Ticket 030 can be considered fully validated end-to-end.

Current state:

Terraform OIDC Infrastructure      ✅
IAM Role                           ✅
Least-Privilege ECR Policy         ✅
AWS CLI Verification               ✅
GitHub Workflow Configuration      ✅
pytest / Docker CI Foundation      ✅
End-to-End ECR Publishing          ⏳ Troubleshooting

⸻

## Troubleshooting Approach

The next investigation step is to inspect the first failed step in the GitHub Actions test-and-build job.

The likely validation points are:

Configure AWS credentials
        ↓
Login to Amazon ECR
        ↓
Tag and push image to ECR

The first failing stage will be identified from GitHub Actions logs and corrected before final Ticket 030 closure.

⸻

## Evidence

Terraform OIDC / IAM Provisioning

GitHub Actions ECR Workflow

ECR Image Publishing Configuration

⸻


⸻
## Key Takeaways

* Implemented AWS authentication for GitHub Actions using OIDC.
* Avoided storing long-lived AWS access keys in GitHub.
* Provisioned the OIDC provider and IAM role through Terraform.
* Restricted the IAM trust policy to the Project Atlas repository and main branch.
* Applied least-privilege ECR permissions to the GitHub Actions role.
* Extended the existing CI pipeline with AWS authentication and ECR publishing.
* Added Git commit SHA container tagging for artifact traceability.
* Verified IAM infrastructure directly through the AWS CLI.
* Identified that CI/CD implementation requires both infrastructure validation and end-to-end pipeline validation.
* Preserved a real troubleshooting scenario for continued incident investigation.

⸻

## Result

Project Atlas now has the infrastructure and workflow configuration required for secure GitHub Actions authentication to AWS and automated Amazon ECR publishing.

The delivery architecture has progressed from:

git push
    ↓
pytest
    ↓
Docker Build
    ↓
CI Success

toward:

git push
    ↓
pytest
    ↓
Docker Build
    ↓
GitHub OIDC
    ↓
AWS IAM Role
    ↓
Amazon ECR

The final end-to-end ECR publishing validation remains in progress and will be completed after diagnosing the current GitHub Actions failure.
