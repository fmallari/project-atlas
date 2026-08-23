# Ticket 031 — Containerized Deployment with Amazon ECR

## Objective

Containerize Project Atlas and establish a production deployment path using Docker, Amazon ECR, GitHub Actions, AWS IAM/OIDC, EC2, and Nginx.

The goal was to move Project Atlas away from relying solely on a host-managed Python/Gunicorn runtime and toward a repeatable container-based deployment model.

## Architecture

Deployment flow:

Git push
→ GitHub Actions
→ Automated tests
→ Docker image build
→ AWS authentication using GitHub OIDC
→ Push image to Amazon ECR
→ EC2 pulls image from ECR
→ Docker runs application container
→ Nginx proxies production traffic to container
→ Gunicorn serves Flask application

Production request path:

Internet
→ HTTPS / Nginx
→ 127.0.0.1:8080
→ Docker container port 8000
→ Gunicorn
→ Flask / Project Atlas

## Implementation

### 1. Containerized the Application

Project Atlas was packaged into a Docker image with Gunicorn serving the Flask application.

The container exposes port 8000 and runs:

    gunicorn --bind 0.0.0.0:8000 app:app

### 2. CI Pipeline

GitHub Actions was configured to:

- Check out the repository
- Configure Python
- Install dependencies
- Run automated tests with pytest
- Build the Docker image
- Authenticate to AWS using GitHub OIDC
- Authenticate Docker to Amazon ECR
- Tag the image using the Git commit SHA
- Push the image to ECR

Using the Git SHA provides an immutable connection between deployed container artifacts and the source revision that produced them.

### 3. AWS Authentication

GitHub Actions authenticates to AWS using OpenID Connect (OIDC) rather than storing long-lived AWS access keys in GitHub.

An IAM role was created for GitHub Actions with permissions required to push images to the Project Atlas ECR repository.

The EC2 instance uses its own IAM role for ECR read operations.

### 4. ECR Pull Permissions

During deployment, the EC2 instance initially received an AccessDenied error when attempting to describe the ECR repository.

The assumed EC2 role was identified and least-privilege ECR read permissions were added through Terraform.

Required operations included:

- ecr:GetAuthorizationToken
- ecr:BatchCheckLayerAvailability
- ecr:BatchGetImage
- ecr:GetDownloadUrlForLayer
- ecr:DescribeImages
- ecr:DescribeRepositories

After applying the IAM change, EC2 successfully authenticated to ECR and accessed the Project Atlas repository.

### 5. Container Deployment

The SHA-tagged Project Atlas image was pulled from Amazon ECR onto EC2.

The container was started with host port 8080 mapped to container port 8000.

Example runtime path:

    127.0.0.1:8080 → container:8000

Container status and application health were verified using Docker and curl.

The `/health` endpoint returned:

    HTTP/1.1 200 OK

    {
      "service": "project-atlas",
      "status": "healthy",
      "version": "1.0.0"
    }

### 6. Nginx Production Cutover

Before modifying Nginx, the existing Project Atlas configuration was backed up.

Nginx was changed from proxying to the original host-based Gunicorn service on:

    127.0.0.1:5000

to the Docker deployment on:

    127.0.0.1:8080

After reloading Nginx, both the production homepage and health endpoint returned HTTP 200 responses over HTTPS.

### 7. Rollback Strategy

The original systemd-managed Gunicorn service was intentionally kept running during the initial container cutover.

This provides a simple rollback path:

    Container deployment:
    Nginx → 127.0.0.1:8080

    Legacy deployment:
    Nginx → 127.0.0.1:5000

If the containerized deployment fails, Nginx can temporarily be redirected to the existing Gunicorn service while the container issue is investigated.

## Incident — Disk Capacity Exhaustion

During implementation, the EC2 root filesystem reached approximately 96% utilization and prevented files from being saved.

Investigation included:

    df -h /
    du
    find
    journalctl --disk-usage
    apt cache inspection

Old backup archives and unnecessary package cache were removed.

The underlying issue also demonstrated that the original 8 GB root volume provided insufficient operational headroom.

Rather than relying exclusively on manual cleanup, the EC2 root EBS volume was updated through Terraform from:

    8 GB → 12 GB

After the filesystem was expanded, root filesystem utilization dropped to approximately:

    62%

This provided additional capacity for Docker images, application artifacts, logs, package updates, and normal system operation.

## Validation

The deployment was validated at multiple layers:

- GitHub Actions tests passed
- Docker image built successfully
- GitHub Actions authenticated to AWS through OIDC
- Image pushed successfully to Amazon ECR
- EC2 authenticated to ECR through its IAM role
- SHA-tagged image pulled successfully
- Docker container remained running
- Container health endpoint returned HTTP 200
- Nginx successfully proxied traffic to the container
- Public HTTPS health endpoint returned HTTP 200
- Production homepage returned HTTP 200
- Legacy Gunicorn service remained available for rollback

## Evidence

- `ecr-image-verification.png`
- `container-health-check.png`
- `production-container-cutover.png`
- `disk-capacity-remediation.png`

## Result

Project Atlas now has a containerized production deployment path backed by Amazon ECR.

Application artifacts are built and tested through GitHub Actions, authenticated to AWS without long-lived credentials, stored in ECR using commit-based image tags, pulled by EC2 using IAM role permissions, and served through Docker behind the existing Nginx HTTPS endpoint.

The original host-based Gunicorn deployment remains temporarily available as a rollback mechanism.

## Next Step

Automate the EC2 deployment stage so a successful CI build can deploy the new ECR image, replace the running container, perform a health check, and safely handle deployment failure.

This will extend the existing CI pipeline toward a complete CI/CD workflow.
