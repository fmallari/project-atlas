# Project Atlas

A production-style AWS Cloud Engineering and Site Reliability Engineering environment focused on secure deployment, observability, incident response, and repeatable operations.

Project Atlas demonstrates how I design, deploy, secure, monitor, troubleshoot, and document a Linux-hosted application on AWS.

Rather than treating each milestone as an isolated tutorial, I manage the project through engineering tickets that include an objective, implementation plan, validation evidence, incident notes, operational lessons, and runbook updates.

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

## Current Architecture

                      Internet
                     │
                  HTTPS
                     │
               Amazon Route53
                     │
              Nginx Reverse Proxy
                     │
                Gunicorn WSGI
                     │
                Flask Application
                 │            │
                 │            ▼
                 │       Amazon S3
                 │
                 ▼
         Amazon CloudWatch
         │              │
         ▼              ▼
     Dashboards      Alarms
                        │
                        ▼
                    Amazon SNS
                        │
                        ▼
                 Email Notifications

---

# Technology Stack

### Cloud

- AWS EC2

### Operating System

- Ubuntu Linux

### Backend

- Python
- Flask
- Gunicorn

### Web Server

- Nginx

### DevOps

- systemd
- SSH
- Git
- GitHub

### Monitoring & Troubleshooting

- curl
- journalctl
- systemctl
- Nginx Access Logs
- Nginx Error Logs

---

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

# Roadmap

## Sprint 1 – Infrastructure

- ✅ EC2
- ✅ SSH
- ✅ Flask
- ✅ Gunicorn
- ✅ Nginx

## Sprint 2 – Observability

- ✅ Incident Investigation
- ✅ Health Checks

## Sprint 3 – Logging

- ✅ Structured Logging
- ✅ Application Metrics

## Sprint 4 – Containerization

- ⏳ Docker
- ⏳ Docker Compose

## Sprint 5 – Cloud Automation

- ⏳ Terraform
- ⏳ Infrastructure as Code

## Sprint 6 – CI/CD

- ⏳ GitHub Actions

---

# Connect

GitHub: https://github.com/fmallari

LinkedIn: https://www.linkedin.com/in/fmallari/
