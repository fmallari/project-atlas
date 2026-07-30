# Objective

Build a centralized operational dashboard in Amazon CloudWatch to visualize the health and performance of the Project Atlas infrastructure and application.

The dashboard combines native EC2 metrics with custom metrics published by the Amazon CloudWatch Agent, providing a single pane of glass for monitoring the production environment.

⸻

## Background

After centralizing application logs in Ticket 011, the next step was to move from reactive troubleshooting to proactive monitoring.

Rather than investigating issues only after users experience problems, operational dashboards allow engineers to continuously monitor infrastructure health, application performance, and resource utilization.

This mirrors how Cloud Engineers and Site Reliability Engineers monitor production systems.

⸻

## Architecture

                Browser
                    │
                    ▼
             Flask Application
                    │
                    ▼
               Gunicorn Service
                    │
                    ▼
              Nginx Reverse Proxy
                    │
                    ▼
────────────────────────────────────
Amazon CloudWatch Agent
────────────────────────────────────
        │                 │
        │                 │
        ▼                 ▼
  Log Groups        Custom Metrics
        │                 │
        └──────────┬──────┘
                   ▼
        Amazon CloudWatch Dashboard

⸻

# Technologies Used

* Amazon EC2
* Ubuntu Linux
* Amazon CloudWatch
* Amazon CloudWatch Agent
* CloudWatch Dashboards
* IAM Roles
* Flask
* Gunicorn
* Nginx

⸻

# Dashboard Metrics

## Custom Metrics

Published by the CloudWatch Agent:

* Memory Utilization (mem_used_percent)
* Disk Utilization (disk_used_percent)

⸻

## Native AWS Metrics

Collected automatically by EC2:

* CPUUtilization
* NetworkIn
* NetworkOut
* StatusCheckFailed
* StatusCheckFailed_Instance
* StatusCheckFailed_System

⸻

## Implementation

Completed the following tasks:

* Installed and configured the Amazon CloudWatch Agent.
* Verified custom metrics were successfully published under the ProjectAtlas namespace.
* Created a CloudWatch Dashboard named:

ProjectAtlas-Operations

Added widgets for:

* Memory Utilization
* Disk Utilization
* CPU Utilization
* Network In
* Network Out
* EC2 Status Checks

Organized the widgets into a single operational dashboard for real-time monitoring.

⸻

# Validation

Validated successful metric collection by confirming:

✅ Memory metrics updated continuously.

✅ Disk utilization updated continuously.

✅ CPU utilization reflected application activity.

✅ Network traffic increased during testing.

✅ EC2 Status Checks remained healthy (0).

Observed a CPU and network utilization spike while restarting the CloudWatch Agent and testing the application, confirming the dashboard accurately reflected live infrastructure activity.

Evidence

Include screenshots such as:

screenshots/Ticket-012/
│
├── 01-dashboard-overview.png
├── 02-memory-widget.png
├── 03-disk-widget.png
├── 04-cpu-widget.png
├── 05-network-widget.png
└── 06-status-check-widget.png

⸻

# Lessons Learned

* CloudWatch supports combining AWS-managed and custom metrics in a single dashboard.
* Custom metrics provide visibility into operating system resources that EC2 does not publish by default.
* Operational dashboards allow engineers to quickly identify abnormal system behavior.
* Correlating CPU, network activity, and deployment events helps validate infrastructure changes.

⸻

# Production Takeaways

Operational dashboards reduce the time required to investigate incidents by consolidating infrastructure health into a single view.

This implementation establishes the foundation for proactive monitoring and alerting, enabling future CloudWatch alarms and automated notifications.

⸻

# Skills Demonstrated

### Cloud

* Amazon CloudWatch Dashboards
* CloudWatch Agent
* Custom Metrics
* EC2 Monitoring
* IAM Roles

### Linux

* Agent configuration
* Service management
* Log validation

### Operations

* Infrastructure monitoring
* Observability
* Operational dashboard design
* Performance validation

### Site Reliability Engineering

* System health monitoring
* Infrastructure telemetry
* Metrics correlation
* Incident readiness

⸻

## Commands Used

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status

sudo cat /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.toml

sudo tail -n 100 /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log

aws cloudwatch list-metrics --namespace ProjectAtlas
