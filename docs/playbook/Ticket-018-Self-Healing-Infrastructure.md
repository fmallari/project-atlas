# Ticket 018 – Self-Healing Infrastructure

## Objective

Automatically recover the application whenever Gunicorn becomes unavailable by integrating CloudWatch, EventBridge, Systems Manager, and Run Command.

# Architecture

Gunicorn Stops
      │
      ▼
Nginx Returns 502
      │
      ▼
CloudWatch Logs
      │
      ▼
Metric Filter
      │
      ▼
CloudWatch Alarm
      │
      ├────────► SNS Email
      │
      ▼
EventBridge Rule
      │
      ▼
Systems Manager
      │
      ▼
Run Command Document
      │
      ▼
Restart Gunicorn
      │
      ▼
Website Restored

## What I Built

- Created custom Systems Manager Run Document
- Restarted Gunicorn using Run Command
- Created EventBridge Rule
- Connected CloudWatch Alarm to Systems Manager
- Automated application recovery

## Validation

Test Procedure

1. Stopped Gunicorn.
2. Website returned HTTP 502.
3. CloudWatch Metric detected failure.
4. Alarm transitioned to ALARM.
5. SNS email notification received.
6. EventBridge triggered.
7. Systems Manager executed Run Command.
8. Gunicorn restarted automatically.
9. Website recovered successfully.

## Results

The application successfully recovered without manual SSH access.

Recovery was completed automatically through AWS native services.

This implementation demonstrates automated incident remediation commonly used in production cloud environments.

## Lessons Learned

Monitoring is valuable, but automation significantly reduces Mean Time To Recovery (MTTR).

Combining CloudWatch, EventBridge, Systems Manager, and Run Command enables reliable self-healing infrastructure while minimizing manual operational effort.
