# Project Atlas

Hi, I’m Francis, a software engineer transitioning into Cloud Engineering and Site Reliability Engineering. Project Atlas is a production-inspired Cloud Engineering and Site Reliability Engineering portfolio project documenting the deployment, operation, monitoring, and continuous improvement of a cloud-hosted web application on AWS.

The project follows an engineering playbook approach where each implementation is documented as an individual ticket, validated through testing, and supported with operational evidence.

Every completed ticket includes:

- Business objective
- Architecture
- Implementation
- Validation
- Incident investigation
- Operational lessons
- Runbook updates

---

## Snapshot

- Cloud platform: AWS
- Infrastructure: EC2, Linux, IAM
- Application stack: Python, Flask, Gunicorn, Nginx
- Observability: Amazon CloudWatch, health checks, system and application logs
- Security: IAM roles and policies, least-privilege access, HTTPS/TLS, DNS
- Operations: systemd, SSH, service validation, incident response, root-cause analysis
- Documentation: Engineering tickets, screenshots, runbooks, architecture notes, and incident reports

## Recent Milestones

- Implemented CloudWatch dashboards
- Configured CPU alarms
- Integrated SNS email notifications
- Simulated production CPU load
- Validated alerting pipeline end-to-end

## Engineering Principles

Project Atlas follows a simple engineering philosophy:

> Gather evidence before making changes.

Every operational decision is supported by logs, validation, testing, or system observations.

---

## Live Application

🌐 https://francismallari.dev

Repository: https://github.com/fmallari/project-atlas


---

## 🌟 Portfolio Highlights

- Provisioned cloud infrastructure on AWS EC2
- Deployed a production-style Flask application
- Configured Gunicorn with systemd
- Implemented Nginx as a reverse proxy
- Performed structured incident investigations using Linux logs
- Built and validated application health checks
- Documented engineering tickets, runbooks, and operational lessons
                         Internet
                              │
                           HTTPS
                              │
                     francismallari.dev
                              │
                              ▼
                    Nginx Reverse Proxy
                              │
                              ▼
                    Gunicorn Application Server
                              │
                              ▼
                      Flask Web Application
                       │                  │
                       ▼                  ▼
                 Amazon S3         CloudWatch Logs
                                          │
                                          ▼
                                CloudWatch Metrics
                                          │
                                          ▼
                                 CloudWatch Dashboard
                                          │
                                          ▼
                                 CloudWatch Alarms
                                          │
                                          ▼
                                      Amazon SNS
                                          │
                                          ▼
                                 Email Notifications

---

# Technology Stack 

Capability | Technologies 

Cloud Infrastructure | EC2, IAM, S3

Web Stack | Flask, Gunicorn, Nginx

Security | IAM Roles, HTTPS, Let’s Encrypt

Observability | CloudWatch Logs, Metrics, Dashboards

Alerting | CloudWatch Alarms, Amazon SNS

Linux | Ubuntu, systemd, SSH

Operations | Incident Response, Health Checks, Monitoring

---

# Production Features

✅ Production deployment on Amazon EC2

✅ Nginx reverse proxy

✅ Gunicorn application server

✅ HTTPS with Let’s Encrypt

✅ Health endpoint monitoring

✅ Secure S3 uploads using IAM Roles

✅ Centralized CloudWatch logging

✅ Custom memory & disk metrics

✅ CloudWatch operational dashboard

✅ CloudWatch alarms

✅ Amazon SNS email notifications

✅ Incident simulation & validation

## Completed Engineering Tickets

| Ticket | Description | Status |
|---------|-------------|--------|
| ✅ 001 | EC2 & SSH | Complete |
| ✅ 002 | Python Environment | Complete |
| ✅ 003 | Flask Deployment | Complete |
| ✅ 004 | Nginx | Complete |
| ✅ 005 | Health Checks | Complete |
| ✅ 006 | Log Analysis | Complete |
| ✅ 007 | HTTPS with Let's Encrypt | Complete |
| ✅ 008 | Production Health Checks | Complete |
| ✅ 009 | Incident Response | Complete |
| ✅ 010 | Configure IAM permissions | Complete |
| ✅ 011 | Implement CloudWatch visibility | Complete |
| ✅ 012 | Dashboards | Complete |
| ✅ 013 | Alarms & SNS | Complete |

---

# Repository Structure

```text
project-atlas/
│
├── docs/
│   ├── playbook/
│   ├── incidents/
│   └── runbooks/
│
├── architecture/
│
├── screenshots/
│
├── app/
│
└── README.md
```
---

# 🎯 Skills Demonstrated

Cloud Engineering

* AWS EC2
* Amazon S3
* IAM Roles
* CloudWatch
* SNS

Linux Administration

* Ubuntu
* SSH
* systemd
* journalctl

Site Reliability Engineering

* Monitoring
* Alerting
* Incident Response
* Root Cause Analysis
* Operational Validation

Networking

* Nginx
* HTTPS
* DNS
* Reverse Proxy

Software Engineering

* Flask
* Python
* Git
* GitHub

# 🛣 Roadmap

✅ Completed

* Production Deployment
* HTTPS
* IAM Roles
* S3 Integration
* CloudWatch Logs
* Metrics
* Dashboards
* Alerts
* SNS Notifications

🚧 In Progress

* Automated Backups
* Disaster Recovery

🔜 Planned

* Terraform Infrastructure as Code
* CI/CD with GitHub Actions
* Load Balancer
* Auto Scaling
* Docker
* Amazon ECS

Upcoming

⬜ Automated Backups
⬜ Disaster Recovery
⬜ Infrastructure as Code (Terraform)
⬜ CI/CD
⬜ Docker
⬜ ECS

---

📫 Connect

If you’d like to further discuss Cloud Engineering, Site Reliability Engineering, or software development, feel free to connect with me via LinkedIn: https://www.linkedin.com/in/fmallari/
