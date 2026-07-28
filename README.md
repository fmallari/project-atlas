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

## Selected Engineering Outcomes

- Deployed and operated a production-style Python application on AWS EC2.
- Configured Nginx as a reverse proxy and Gunicorn as a systemd-managed application service.
- Secured public application traffic using DNS and HTTPS/TLS.
- Implemented application health checks and Amazon CloudWatch monitoring for operational visibility.
- Configured IAM roles and policies to provide controlled access to AWS services.
- Investigated and resolved service failures using systemctl, journalctl, application logs, Nginx logs, and endpoint validation.
- Documented infrastructure changes, validation results, incidents, and recovery procedures through reusable engineering playbooks.

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
                             ▼
                    DNS / Custom Domain
                             │
                             ▼
                         HTTPS/TLS
                             │
                             ▼
                    ┌─────────────────┐
                    │      Nginx      │
                    │  Reverse Proxy  │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │    Gunicorn     │
                    │  systemd Service│
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   Flask App     │
                    │ / and /health   │
                    └─────────────────┘
                             │
                  ┌──────────┴──────────┐
                  ▼                     ▼
          Amazon CloudWatch      Linux / App Logs
          Metrics and Logs       journalctl / Nginx

                    Hosted on AWS EC2
                 Access controlled with IAM

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
| ✅ 001 | Provision AWS EC2 Development Server | Complete |
| ✅ 002 | Deploy Flask Application | Complete |
| ✅ 003 | Configure Gunicorn Application Server | Complete |
| ✅ 004 | Configure Nginx Reverse Proxy | Complete |
| ✅ 005 | Investigate Production Incident | Complete |
| ✅ 006 | Implement Application Health Checks | Complete |
| ✅ 007 | HTTPS with Let's Encrypt | Complete |
| ✅ 008 | Validate production health | Complete |
| ✅ 009 | Resolve 502 service failure | Complete |
| ✅ 010 | Configure IAM permissions | Complete |
| ✅ 011 | Implement CloudWatch visibility | Complete |

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

- ⏳ Structured Logging
- ⏳ Application Metrics

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
