# 🚀 Project Atlas

> Building production-ready Cloud Engineering skills through hands-on AWS infrastructure, Linux administration, and DevOps projects.

![Status](https://img.shields.io/badge/Status-In%20Progress-blue)
![AWS](https://img.shields.io/badge/AWS-EC2-orange)
![Python](https://img.shields.io/badge/Python-3.x-blue)
![Linux](https://img.shields.io/badge/Ubuntu-24.04-E95420)
![Nginx](https://img.shields.io/badge/Nginx-Reverse%20Proxy-green)
![Gunicorn](https://img.shields.io/badge/Gunicorn-WSGI-lightgrey)

---

# Overview

Project Atlas documents my transition into Cloud Engineering by treating every lesson as a production engineering ticket rather than a tutorial.

Instead of simply deploying applications, this repository demonstrates how cloud infrastructure is provisioned, validated, monitored, documented, and improved using real engineering workflows.

Every completed ticket includes:

- Business objective
- Architecture
- Implementation
- Validation
- Incident investigation
- Operational lessons
- Runbook updates
- Resume-ready accomplishments

---

# Current Architecture

```text
                Internet
                    │
                    ▼
             ┌─────────────┐
             │    Nginx    │
             │ ReverseProxy│
             └─────────────┘
                    │
                    ▼
             ┌─────────────┐
             │  Gunicorn   │
             │ WSGI Server │
             └─────────────┘
                    │
                    ▼
             ┌─────────────┐
             │ Flask App   │
             └─────────────┘
                    │
                    ▼
              Ubuntu EC2
```

---

# Technology Stack

## Cloud

- AWS EC2

## Operating System

- Ubuntu Linux

## Backend

- Python
- Flask
- Gunicorn

## Web Server

- Nginx

## DevOps

- systemd
- SSH
- Git
- GitHub

## Monitoring & Troubleshooting

- curl
- journalctl
- systemctl
- Nginx Access Logs
- Nginx Error Logs

---

# Completed Engineering Tickets

| Ticket | Description | Status |
|---------|-------------|--------|
| ✅ 001 | Provision AWS EC2 Development Server | Complete |
| ✅ 002 | Deploy Flask Application | Complete |
| ✅ 003 | Configure Gunicorn Application Server | Complete |
| ✅ 004 | Configure Nginx Reverse Proxy | Complete |
| ✅ 005 | Investigate Production Incident | Complete |
| ✅ 006 | Implement Application Health Checks | Complete |

---

# Engineering Principles

Project Atlas follows a simple engineering philosophy:

> Gather evidence before making changes.

Every operational decision is supported by logs, validation, testing, or system observations.

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

# Skills Demonstrated

- Linux Administration
- Cloud Infrastructure
- Python Development
- Flask Deployment
- Gunicorn Configuration
- Nginx Administration
- Reverse Proxy Configuration
- Linux Service Management
- HTTP Troubleshooting
- Application Monitoring
- Incident Investigation
- Git Version Control
- Technical Documentation

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

## Featured Lessons

- How Nginx and Gunicorn work together
- Why `/health` endpoints matter
- Using `journalctl` for incident response
- Validating infrastructure with `curl`
- Reading Nginx access and error logs

# Why This Repository Exists

This repository documents my journey from software development into Cloud Engineering.

My goal isn't simply to build applications.

My goal is to build, operate, troubleshoot, document, and continuously improve reliable cloud infrastructure using industry-standard engineering practices.

---

# Connect

GitHub: https://github.com/fmallari

LinkedIn: https://www.linkedin.com/in/fmallari/
