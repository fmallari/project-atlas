# Ticket 017 – CloudWatch Metric Filters and Alarms

## Objective

Create proactive monitoring by converting Nginx error logs into CloudWatch metrics and configuring CloudWatch alarms to notify operators whenever HTTP 502 Bad Gateway errors occur.

# Architecture 

Nginx Error Logs
        │
        ▼
CloudWatch Logs
        │
        ▼
Metric Filter
        │
        ▼
Custom Metric (Nginx502Count)
        │
        ▼
CloudWatch Alarm
        │
        ▼
SNS Email Notification

## What I Built

- Created CloudWatch Metric Filter
- Parsed Nginx error logs
- Counted every HTTP 502 Bad Gateway event
- Published custom metric:
  - Namespace: ProjectAtlas/Application
  - Metric: Nginx502Count
- Configured CloudWatch Alarm
- Created SNS Topic
- Verified email notifications

## Validation

Successfully generated a 502 Bad Gateway error.

Verified:

- CloudWatch metric increased
- Alarm entered ALARM state
- SNS email notification received

## Lessons Learned

CloudWatch Metric Filters transform application log events into operational metrics.

Instead of manually checking logs, engineers receive proactive notifications whenever application failures occur.
