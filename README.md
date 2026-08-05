# Project Atlas

Project Atlas is a production-inspired Cloud Engineering and Site Reliability Engineering portfolio project documenting the deployment, operation, monitoring, and continuous improvement of a cloud-hosted web application on AWS.

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

## 🎯 Project Goals

- Build and operate a production-style cloud environment

- Learn AWS services through hands-on implementation

- Practice Site Reliability Engineering (SRE) workflows

- Document every change as an engineering playbook

- Simulate real-world incidents and recovery procedures

---

## 🏗️ Architecture

```text

                    Internet

                        │

                        ▼

                  HTTPS (TLS)

                        │

                        ▼

                     Nginx

                        │

                        ▼

                    Gunicorn

                        │

                        ▼

                 Flask Application

                        │

                        ▼

                       S3

```

---

## 📈 Observability Pipeline

```text

                Nginx Logs

                     │

                     ▼

             CloudWatch Logs

                     │

                     ▼

              Metric Filter

                     │

                     ▼

        Nginx502Count Metric

                     │

                     ▼

            CloudWatch Alarm

                     │

             ┌───────────────┐

             ▼               ▼

        SNS Notification   EventBridge

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

---

## ✅ Skills Demonstrated

### Infrastructure

- AWS EC2 (Ubuntu)

- IAM Roles

- Security Groups

- Amazon S3

- Route53 / DNS

- HTTPS (Let's Encrypt)

### Application

- Flask

- Gunicorn

- Nginx Reverse Proxy

### Monitoring

- CloudWatch Logs

- CloudWatch Metrics

- CloudWatch Dashboard

- Metric Filters

- Custom Metrics

- CloudWatch Alarms

### Operations

- SNS Email Alerts

- Systems Manager

- Fleet Manager

- Session Manager

- Run Command

### Reliability

- Automated Nightly Backups

- Disaster Recovery Documentation

- Self-Healing Infrastructure

---

## 🚨 Example Production Incident

### Failure

Gunicorn unexpectedly stopped.

### Detection

CloudWatch Metric Filter detected HTTP 502 responses.

### Alerting

CloudWatch Alarm entered **ALARM** state.

SNS immediately sent an email notification.

### Automated Recovery

EventBridge triggered Systems Manager.

Systems Manager executed:

```bash

sudo systemctl restart gunicorn

```

### Result

The application recovered automatically without SSH access.

---

## 📚 Engineering Playbook

Every implementation is documented with:

- Objectives

- Architecture

- Commands Used

- Validation

- Lessons Learned

- Operational Takeaways

- Incident Documentation

- Screenshots

Current completed tickets:

- ✅ Ticket 001 – EC2 Deployment

- ✅ Ticket 002 – Python Environment

- ✅ Ticket 003 – Gunicorn

- ✅ Ticket 004 – Nginx

- ✅ Ticket 005 – Health Checks

- ✅ Ticket 006 – Log Analysis

- ✅ Ticket 007 – HTTPS

- ✅ Ticket 008 – Production Health Checks

- ✅ Ticket 009 – Incident Response

- ✅ Ticket 010 – S3 Uploads

- ✅ Ticket 011 – CloudWatch

- ✅ Ticket 012 – CloudWatch Dashboard

- ✅ Ticket 013 – CloudWatch Alarms & SNS

- ✅ Ticket 014 – Automated Backups

- ✅ Ticket 015 – Systems Manager

- ✅ Ticket 017 – CloudWatch Metric Filters

- ✅ Ticket 018 – Self-Healing Infrastructure

---

## 🛠️ Technologies

AWS

- EC2

- IAM

- S3

- CloudWatch

- SNS

- Systems Manager

- EventBridge

Linux

- Ubuntu

- Bash

- Cron

Application

- Flask

- Gunicorn

- Nginx

---

## 🚀 Roadmap

### Completed

- EC2 Deployment

- HTTPS

- CloudWatch Monitoring

- Systems Manager

- Automated Backups

- Self-Healing Infrastructure

### Coming Next

- Terraform (Infrastructure as Code)

- Docker

- GitHub Actions CI/CD

- Application Load Balancer

- Auto Scaling

- Multi-AZ Deployment

- Kubernetes

- Chaos Engineering

---

## 👨‍💻 Author

**Francis Mallari**

Cloud Engineer / Site Reliability Engineer Portfolio Project
---

📫 Connect

If you’d like to further discuss Cloud Engineering, Site Reliability Engineering, or software development, feel free to connect with me via LinkedIn: https://www.linkedin.com/in/fmallari/
