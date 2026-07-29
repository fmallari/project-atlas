# Ticket 011 – Centralized Logging with Amazon CloudWatch

## Sprint

Sprint 3 – Observability

---

# Objective

Implement centralized logging for Project Atlas by integrating Amazon CloudWatch Logs with the production EC2 instance. Configure the CloudWatch Agent to securely stream Nginx access and error logs, enabling engineers to investigate application behavior without requiring SSH access to the server.

---

# Background

Prior to this implementation, application troubleshooting relied on directly connecting to the EC2 instance and manually reviewing logs using journalctl and Linux log files.

While functional, this approach does not scale well in production environments where engineers require centralized visibility across services.

Amazon CloudWatch Logs provides a managed logging platform that aggregates logs, supports full-text searching, enables log analytics through Logs Insights, and forms the foundation for monitoring and alerting.

---

# Architecture

                Internet
                    │
                    ▼
              Nginx Web Server
                    │
      ┌─────────────┴─────────────┐
      ▼                           ▼
Access Log                 Error Log
      │                           │
      └─────────────┬─────────────┘
                    ▼
        Amazon CloudWatch Agent
                    │
                    ▼
         Amazon CloudWatch Logs
                    │
                    ▼
           Logs Insights Queries
# Technologies Used

- Amazon EC2
- Ubuntu 24.04 LTS
- Amazon CloudWatch
- CloudWatch Agent
- IAM Roles
- IMDSv2
- AWS STS
- Nginx
- Gunicorn
- systemd
- Linux

# Implementation

## Step 1

Validated IAM Role authentication using AWS STS.

Verified that the EC2 instance assumed the projectatlas-ec2role role and that temporary credentials were issued automatically.

---

## Step 2

Validated IMDSv2 metadata service.

Confirmed the EC2 instance retrieved metadata using session tokens instead of IMDSv1.

---

## Step 3

Installed the Amazon CloudWatch Agent.

Since Ubuntu repositories do not contain the package, the official AWS .deb package was downloaded and installed.

---

## Step 4

Created a CloudWatch Agent configuration.

Configured log collection for:

- /var/log/nginx/access.log
- /var/log/nginx/error.log

Configured unique log streams using the EC2 instance ID.

---

## Step 5

Validated CloudWatch Agent configuration.

Confirmed:

- JSON syntax validation
- Agent configuration validation
- Successful startup

---

## Step 6

Verified CloudWatch Log Groups.

Automatically created:

project-atlas/nginx/access

project-atlas/nginx/error

---

## Step 7

Verified Log Streams.

Confirmed the CloudWatch Agent created an instance-specific log stream.

---

## Step 8

Validated Live Log Ingestion.

Generated browser traffic and verified Nginx access logs appeared in CloudWatch within seconds.

---

## Step 9

Reviewed Gunicorn lifecycle events.

Validated service restarts using the systemd journal.

Observed:

- Graceful shutdown
- Worker termination
- Service restart
- Worker initialization
- Successful application startup

# Validation

The implementation was considered successful after verifying:

✅ CloudWatch Agent installed

✅ Agent configuration validated

✅ IAM Role authentication

✅ IMDSv2 authentication

✅ CloudWatch Log Groups created

✅ CloudWatch Log Streams created

✅ Live Nginx access logs visible

✅ Successful browser requests recorded

✅ Gunicorn lifecycle validated using systemd journal

# Operational Observations

CloudWatch immediately revealed unsolicited internet scan activity against the public-facing server.

Observed requests included:

- WordPress
- Nextcloud
- .env files
- php configuration files

These requests were expected background internet scanning activity.

Application requests generated during Nginx troubleshooting clearly showed the progression from unsuccessful requests to successful HTTP 200 responses after correcting the server configuration.

This demonstrated the value of centralized logging for reconstructing production incidents.

# Production Incident Timeline

Problem observed

↓

HTTP 404 responses

↓

Investigated Nginx configuration

↓

Updated server_name

↓

Reloaded Nginx

↓

CloudWatch logs confirmed HTTP 200 responses

↓

Service restored

# Lessons Learned

- Centralized logging significantly reduces troubleshooting time.

- IAM Roles eliminate the need for long-lived AWS credentials.

- IMDSv2 improves instance credential security.

- CloudWatch provides immediate operational visibility.

- Internet-facing servers continuously receive automated scan traffic.

- Logs provide the evidence necessary to reconstruct production events.

  # Engineering Reflection

This ticket fundamentally changed the operational model of Project Atlas.

Rather than depending on SSH access for routine investigations, operational visibility now exists through Amazon CloudWatch.

The implementation demonstrated how centralized logging improves troubleshooting efficiency while providing historical context for production incidents.

Reviewing live internet traffic and service lifecycle events reinforced the importance of observability as a core component of production systems rather than an optional enhancement.

# Skills Demonstrated

Cloud Engineering

- Amazon CloudWatch
- IAM Roles
- STS
- IMDSv2

Linux

- systemd
- journalctl
- Nginx

Operations

- Centralized Logging
- Log Validation
- Incident Investigation
- Operational Analysis

Security

- Temporary Credentials
- Least Privilege
- Secure Metadata Access

  # Evidence

01-imdsv2-iam-role-validation.png

02-cloudwatch-agent-installed.png

03-cloudwatch-agent-config.png

04-cloudwatch-config-validation.png

05-cloudwatch-log-groups.png

06-cloudwatch-log-stream.png

07-cloudwatch-log-events.png

08-logs-insights-top-ips.png

09-logs-insights-status-codes.png

10-logs-insights-recent-requests.png

11-gunicorn-systemd-journal.png
