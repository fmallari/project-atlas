# Project Atlas

> A production-inspired Cloud Engineering and Site Reliability Engineering environment built on AWS to practice infrastructure automation, observability, incident response, containerization, and operational reliability.

Project Atlas is a hands-on Cloud Engineering / Site Reliability Engineering portfolio project documenting the evolution of a cloud-hosted application from a manually operated EC2 workload into an increasingly automated, observable, and reproducible cloud platform.

Rather than treating the project as a collection of isolated tutorials, Project Atlas follows an **engineering playbook model**.

Infrastructure changes, incidents, reliability improvements, and architectural decisions are documented as individual engineering tickets with implementation details, validation steps, operational lessons, and supporting evidence.

Live demo: https://francismallari.dev

---

## 🏗️ Architecture

```text
                         Internet
                            │
                            ▼
                      HTTPS / TLS
                            │
                            ▼
                          Nginx
                            │
                            ▼
                         Gunicorn
                            │
                            ▼
                    Flask Application
                       │          │
                       ▼          ▼
                      S3      Health Checks


              Infrastructure Management
                       │
                       ▼
                    Terraform
                       │
          ┌────────────┼─────────────┐
          ▼            ▼             ▼
         VPC         Subnet     Security Group
          │
          ├── Internet Gateway
          │
          ├── Route Table
          │
          ├── EC2
          │
          └── Amazon ECR


                 Container Workflow
                       │
                       ▼
                  Docker Build
                       │
                       ▼
             project-atlas:latest
                       │
                       ▼
                  Amazon ECR
```

Project Atlas currently combines traditional EC2-based application operations with Infrastructure as Code and containerization as the platform evolves toward automated deployment.

---

## 🔭 Observability & Reliability

Project Atlas includes a monitoring and automated recovery workflow built around Amazon CloudWatch.

```text
Nginx / Application Logs
          │
          ▼
    CloudWatch Logs
          │
          ▼
     Metric Filter
          │
          ▼
   Custom 502 Metric
          │
          ▼
   CloudWatch Alarm
          │
     ┌────┴────┐
     ▼         ▼
    SNS    EventBridge
               │
               ▼
        Systems Manager
               │
               ▼
        Restart Gunicorn
               │
               ▼
      Application Healthy
```

This allows application failures to move through a production-style lifecycle:

**Detect → Alert → Respond → Recover → Validate**

---

# 🧰 Skills Demonstrated

## Infrastructure & AWS

- Amazon EC2
- VPC Networking
- Subnets
- Internet Gateways
- Route Tables
- Security Groups
- IAM Roles
- Amazon S3
- Amazon ECR
- DNS
- HTTPS / TLS

## Infrastructure as Code

- Terraform
- Terraform State
- Terraform Resource Imports
- Variables
- Outputs
- Infrastructure Validation
- Existing Infrastructure Adoption

## Containers

- Docker
- Dockerfiles
- Container Image Builds
- Container Runtime
- Port Publishing
- Container Logging
- Amazon ECR Authentication
- Image Tagging
- Container Registry Publishing

## Application & Linux

- Python
- Flask
- Gunicorn
- Nginx
- Ubuntu Linux
- Bash
- systemd
- Cron

## Observability

- CloudWatch Logs
- CloudWatch Metrics
- CloudWatch Dashboards
- Metric Filters
- Custom Metrics
- CloudWatch Alarms
- Health Checks

## Operations & Reliability

- Incident Investigation
- Log Analysis
- SNS Alerting
- AWS Systems Manager
- Session Manager
- Run Command
- Automated Backups
- Disaster Recovery
- Self-Healing Infrastructure

---

# 🧱 Infrastructure as Code

A major phase of Project Atlas involved transitioning existing AWS infrastructure under **Terraform management**.

Instead of rebuilding the environment from scratch, existing AWS resources were identified, modeled in Terraform configuration, and imported into Terraform state.

Terraform currently manages infrastructure including:

```text
VPC
│
├── Subnet
├── Internet Gateway
├── Route Table
├── Security Group
├── EC2
└── Amazon ECR
```

Infrastructure changes are validated using:

```bash
terraform fmt
terraform validate
terraform plan
```

A clean Terraform plan verifies that the declared configuration matches the deployed AWS infrastructure.

```text
No changes. Your infrastructure matches the configuration.
```

This phase demonstrates an important real-world Infrastructure as Code workflow:

**Discover → Model → Import → Validate → Manage**

---

# 🐳 Containerization

Project Atlas has also begun transitioning from a host-dependent application deployment toward a portable containerized runtime.

The Flask application is packaged into a Docker image containing:

```text
Python Runtime
      │
      ▼
Application Dependencies
      │
      ▼
Project Atlas Flask App
      │
      ▼
Gunicorn
      │
      ▼
Port 8000
```

The image can be built locally with:

```bash
docker build -t project-atlas .
```

and executed with:

```bash
docker run --rm -p 8000:8000 project-atlas
```

Application health can then be verified independently of the EC2 host:

```bash
curl http://localhost:8000/health
```

Example response:

```json
{
  "service": "project-atlas",
  "status": "healthy",
  "version": "1.0.0"
}
```

---

# 📦 Container Registry — Amazon ECR

Terraform provisions a private **Amazon Elastic Container Registry (ECR)** repository for Project Atlas.

The Docker image is:

```text
Built
  ↓
Validated
  ↓
Tagged
  ↓
Authenticated with AWS ECR
  ↓
Pushed
  ↓
Verified in Amazon ECR
```

This establishes a centralized cloud artifact repository that can support future automated deployment and CI/CD workflows.

---

# 🚨 Example Reliability Incident

One Project Atlas exercise simulated an application failure where Gunicorn unexpectedly stopped.

### Detection

CloudWatch detected HTTP `502` responses through a custom metric filter.

### Alerting

A CloudWatch Alarm transitioned into the `ALARM` state and triggered an SNS notification.

### Automated Recovery

EventBridge initiated an AWS Systems Manager action that executed:

```bash
sudo systemctl restart gunicorn
```

### Validation

Application health was checked after remediation to confirm service recovery.

### Result

The application recovered without requiring direct SSH intervention.

This exercise demonstrated:

```text
Failure
   ↓
Detection
   ↓
Alerting
   ↓
Automated Remediation
   ↓
Health Validation
```

---

# 📚 Engineering Playbook

Each Project Atlas implementation is documented as an engineering ticket.

Tickets include:

- Objective
- Architecture
- Implementation
- Commands
- Validation
- Operational Evidence
- Lessons Learned
- Reliability Considerations

### Foundation & Application Operations

- ✅ Ticket 001 — EC2 Deployment
- ✅ Ticket 002 — Python Environment
- ✅ Ticket 003 — Gunicorn
- ✅ Ticket 004 — Nginx
- ✅ Ticket 005 — Health Checks
- ✅ Ticket 006 — Log Analysis
- ✅ Ticket 007 — HTTPS
- ✅ Ticket 008 — Production Health Checks
- ✅ Ticket 009 — Incident Response
- ✅ Ticket 010 — S3 Uploads

### Observability & Reliability

- ✅ Ticket 011 — CloudWatch
- ✅ Ticket 012 — CloudWatch Dashboard
- ✅ Ticket 013 — CloudWatch Alarms & SNS
- ✅ Ticket 014 — Automated Backups
- ✅ Ticket 015 — Systems Manager
- ✅ Ticket 017 — CloudWatch Metric Filters
- ✅ Ticket 018 — Self-Healing Infrastructure

### Infrastructure as Code & Containers

- ✅ Ticket 025 — Terraform-Managed Internet Gateway & Routing
- ✅ Ticket 026 — Terraform Variables & Outputs
- ✅ Ticket 027 — Containerize Project Atlas with Docker
- ✅ Ticket 028 — Publish Project Atlas Container to Amazon ECR

> Additional tickets and operational exercises are documented in [`docs/playbook`](docs/playbook/).

---

# 🛠️ Technology Stack

| Area | Technologies |
|---|---|
| **Cloud** | AWS, EC2, S3, ECR, IAM |
| **Networking** | VPC, Subnets, Internet Gateway, Route Tables, Security Groups, DNS, HTTPS |
| **IaC** | Terraform |
| **Containers** | Docker, Amazon ECR |
| **Application** | Python, Flask, Gunicorn |
| **Web** | Nginx |
| **Observability** | CloudWatch Logs, Metrics, Dashboards, Alarms |
| **Automation** | EventBridge, Systems Manager, Bash, Cron |
| **Operations** | Linux, systemd, SSH, AWS CLI |
| **Version Control** | Git, GitHub |

---

# 🚀 Project Evolution

Project Atlas is intentionally being built in stages.

```text
Application
     ↓
Linux Operations
     ↓
AWS Infrastructure
     ↓
Observability
     ↓
Incident Response
     ↓
Automated Recovery
     ↓
Infrastructure as Code
     ↓
Docker
     ↓
Container Registry
     ↓
CI/CD
     ↓
Automated Container Deployment
```

The goal is not simply to deploy an application.

The goal is to understand how **reliable cloud platforms are built, operated, observed, automated, and improved over time.**

---

# 🗺️ Roadmap

### Completed

- ✅ AWS EC2 Application Deployment
- ✅ Nginx + Gunicorn Production Runtime
- ✅ HTTPS / TLS
- ✅ S3 Integration
- ✅ CloudWatch Monitoring
- ✅ Metrics & Dashboards
- ✅ CloudWatch Alarms
- ✅ SNS Alerting
- ✅ Systems Manager Operations
- ✅ Automated Backups
- ✅ Self-Healing Infrastructure
- ✅ Terraform Infrastructure Management
- ✅ Terraform Resource Imports
- ✅ Terraform Variables & Outputs
- ✅ Docker Containerization
- ✅ Amazon ECR
- ✅ Container Image Publishing

### Next

- 🔄 CI/CD with GitHub Actions
- 🔄 Automated Docker Builds
- 🔄 Automated ECR Publishing
- 🔄 Container Deployment
- 🔄 Application Load Balancer
- 🔄 Auto Scaling
- 🔄 Multi-AZ Architecture

### Future Exploration

- Kubernetes
- Advanced Observability
- Infrastructure Testing
- Chaos Engineering
- Deployment Strategies
- Reliability Engineering Exercises

---

# 👨‍💻 Author

**Francis Mallari**

Cloud Engineer / Platform Engineer / Site Reliability Engineer

Project Atlas is a hands-on engineering portfolio focused on building practical experience operating reliable cloud infrastructure.

### Connect

LinkedIn:  
https://www.linkedin.com/in/fmallari/
