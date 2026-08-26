# Ticket 035 — Proactive Disk Monitoring and SNS Alerting

## Objective

Implement proactive disk monitoring for Project Atlas so that increasing disk utilization can be detected before resource exhaustion affects application availability.

This ticket extends the existing CloudWatch observability configuration by adding:

- Custom EC2 disk utilization metrics through the CloudWatch Agent
- A Terraform-managed CloudWatch alarm
- An Amazon SNS notification topic
- Email alert delivery
- A controlled alarm test and recovery validation

---

## Background

Project Atlas previously experienced a disk exhaustion incident in which accumulated files consumed enough storage to affect application availability.

Recovery required identifying the storage issue, removing unnecessary files, freeing disk capacity, and restoring application services.

Rather than relying only on reactive troubleshooting, this ticket introduces proactive monitoring so disk pressure can be detected before reaching a critical state.

Production alert threshold:

```text
disk_used_percent >= 80%
```

---

## Architecture

The monitoring and notification path is:

```text
EC2 Instance
    |
    v
CloudWatch Agent
    |
    | disk_used_percent
    v
Amazon CloudWatch
    |
    v
CloudWatch Alarm
project-atlas-high-disk-usage
    |
    v
Amazon SNS
project-atlas-alerts
    |
    v
Email Notification
```

---

## CloudWatch Agent Metrics

The CloudWatch Agent was verified as running on the Project Atlas EC2 instance.

Custom metrics are published under the namespace:

```text
ProjectAtlas
```

The configured metrics include:

```text
disk_used_percent
mem_used_percent
```

The disk metric includes dimensions identifying the monitored filesystem:

```text
path       = /
InstanceId = Project Atlas EC2 instance
device     = nvme0n1p1
fstype     = ext4
```

This allows CloudWatch to monitor the root filesystem independently of standard EC2 metrics.

---

## CloudWatch Alarm

The disk alarm is managed through Terraform.

Alarm:

```text
project-atlas-high-disk-usage
```

Metric:

```text
disk_used_percent
```

Namespace:

```text
ProjectAtlas
```

Production threshold:

```text
80%
```

The alarm evaluates the average disk utilization over a 300-second period.

When disk utilization reaches or exceeds the configured threshold, CloudWatch transitions the alarm into the `ALARM` state.

---

## SNS Notification Integration

An SNS topic is used as the notification destination:

```text
project-atlas-alerts
```

An email subscription was configured and confirmed.

Both the alarm and recovery actions are connected to the SNS topic, allowing notifications when the alarm enters either:

```text
ALARM
```

or:

```text
OK
```

---

## Terraform State Reconciliation

During implementation, Terraform attempted to create the SNS topic but AWS returned an error indicating that the topic already existed with different tags.

The existing SNS resource was imported into Terraform state rather than creating a duplicate resource.

After the import, Terraform reported:

```text
No changes. Your infrastructure matches the configuration.
```

This reconciled the existing AWS resource with the Infrastructure as Code configuration.

---

## Controlled Alarm Test

The production threshold of 80% was temporarily reduced to 60% to safely validate the monitoring pipeline.

At the time of the test, root disk utilization was approximately:

```text
70.9%
```

Because:

```text
70.9% >= 60%
```

CloudWatch transitioned the alarm:

```text
OK -> ALARM
```

The alarm reported a threshold crossing for the `disk_used_percent` metric.

This approach allowed the alerting system to be tested without intentionally consuming disk space or risking another resource exhaustion incident.

---

## Notification Validation

After the alarm entered the `ALARM` state, Amazon SNS successfully delivered an AWS CloudWatch notification email.

The notification identified:

```text
Alarm: project-atlas-high-disk-usage
State Change: OK -> ALARM
Metric: disk_used_percent
Namespace: ProjectAtlas
```

This validated the complete notification path:

```text
EC2
  -> CloudWatch Agent
  -> CloudWatch Metric
  -> CloudWatch Alarm
  -> SNS
  -> Email
```

---

## Production Recovery

After validating the notification pipeline, the Terraform configuration was restored to the production threshold:

```text
60% -> 80%
```

Terraform applied the change in place:

```text
Plan: 0 to add, 1 to change, 0 to destroy.
```

After CloudWatch reevaluated the metric, the alarm returned to:

```text
OK
```

CloudWatch confirmed that the current disk utilization was below the restored 80% threshold.

The final production configuration therefore remained:

```text
disk_used_percent >= 80%
```

---

## Validation

The following conditions were successfully verified:

- CloudWatch Agent is running
- Custom `ProjectAtlas` metrics are being published
- `disk_used_percent` is available in CloudWatch
- Terraform manages the CloudWatch alarm
- SNS topic is tracked by Terraform
- Email subscription is confirmed
- Temporary threshold change triggered the alarm
- CloudWatch transitioned from `OK` to `ALARM`
- SNS delivered the alarm notification by email
- Production threshold was restored to 80%
- CloudWatch returned from `ALARM` to `OK`

Final Terraform state was reconciled with the deployed infrastructure.

---

## Engineering Outcome

This ticket changes disk monitoring for Project Atlas from a reactive operational process into a proactive one.

Previously:

```text
Disk fills
-> application is affected
-> troubleshoot outage
-> identify disk exhaustion
-> recover storage
```

With proactive monitoring:

```text
Disk utilization increases
-> CloudWatch detects threshold
-> alarm triggers
-> SNS notifies operator
-> remediation can occur before exhaustion
```

This reduces the likelihood that disk pressure progresses into an application availability incident.

---

## Key Lessons

### Observability should lead to action

Collecting metrics is useful, but an operational monitoring system becomes significantly more valuable when important conditions automatically generate notifications.

### Infrastructure incidents should improve the system

The earlier disk exhaustion incident exposed a monitoring gap. Rather than treating the incident only as a one-time troubleshooting exercise, the failure mode was converted into a permanent monitoring control.

### Terraform state matters

Infrastructure can exist in AWS without being represented in Terraform state. Importing an existing resource allows Terraform to manage that infrastructure without unnecessarily recreating it.

### Production monitoring should be tested safely

Temporarily lowering the alarm threshold provided a controlled method for testing the alert pipeline without intentionally creating dangerous disk utilization.

---

## Skills Demonstrated

- AWS CloudWatch
- CloudWatch Agent
- Custom Linux system metrics
- Amazon SNS
- CloudWatch alarms
- Terraform
- Terraform resource imports
- Infrastructure as Code
- EC2 monitoring
- Linux filesystem monitoring
- Alert testing
- Incident prevention
- Observability
- SRE operational practices

---

## Result

Project Atlas now has proactive disk utilization alerting.

The complete monitoring path was tested successfully:

```text
Metric collected
-> threshold crossed
-> CloudWatch ALARM
-> SNS notification
-> email received
-> production threshold restored
-> CloudWatch OK
```

The production alarm remains configured at an 80% disk utilization threshold.
