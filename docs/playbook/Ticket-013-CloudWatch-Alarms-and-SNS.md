# Ticket 013 — CloudWatch Alarms & SNS Notifications

## Objective

Implement proactive monitoring by configuring Amazon CloudWatch alarms that notify operators when the EC2 instance experiences sustained high CPU utilization.

This ticket builds upon the CloudWatch dashboard created in Ticket 012 by introducing automated alerting and validating the monitoring pipeline using simulated production load.

---

## Architecture

User Traffic
        │
        ▼
    EC2 Instance
        │
        ▼
 CloudWatch Metrics
        │
        ▼
 CloudWatch Alarm
        │
        ▼
     SNS Topic
        │
        ▼
 Email Notification

---

## Technologies Used

- AWS EC2
- Amazon CloudWatch
- Amazon SNS
- Ubuntu 24.04 LTS
- Linux stress utility

---

## Alarm Configuration

Metric

- Namespace: AWS/EC2
- Metric: CPUUtilization
- Statistic: Average
- Period: 5 Minutes

Threshold

- Trigger when CPUUtilization > 70%
- Evaluation Periods: 3
- Datapoints to Alarm: 2 of 3

Notifications

SNS Topic:

project-atlas-alerts

Notifications sent when:

- Alarm enters ALARM state
- Alarm returns to OK state

Recipient:

francis.mallari@icloud.com

---

## Implementation Steps

### 1. Created CloudWatch Alarm

Configured a CPU utilization alarm for the Project Atlas EC2 instance.

Threshold:

CPU > 70%

Evaluation:

2 out of 3 consecutive five-minute periods.

---

### 2. Configured Amazon SNS

Created SNS Topic:

project-atlas-alerts

Subscribed email endpoint.

Verified email subscription.

---

### 3. Added Recovery Notification

Configured the same SNS topic to notify when the alarm returned to the OK state.

This provides visibility into both incident detection and recovery.

---

### 4. Installed Linux Stress Utility

```bash
sudo apt update
sudo apt install stress
```

---

### 5. Simulated High CPU Usage

Executed:

```bash
stress --cpu 2 --timeout 900
```

Verified instance CPU count:

```bash
nproc
```

Output:

```
2
```

The stress utility fully utilized both CPU cores.

---

### 6. Validated Alarm

Observed:

- CPU utilization exceeded 70%
- CloudWatch Alarm transitioned from OK → ALARM
- SNS email notification received
- Dashboard reflected CPU spike

---

### 7. Validated Recovery

After the stress process completed:

- CPU returned to normal
- Alarm transitioned ALARM → OK
- Recovery email received
- Dashboard confirmed utilization normalized

---

## Validation

Verified:

✅ CloudWatch Alarm created

✅ SNS Topic configured

✅ Email subscription confirmed

✅ CPU threshold exceeded

✅ Alarm entered ALARM state

✅ Alarm returned to OK state

✅ Dashboard displayed CPU spike

✅ Email notifications successfully delivered

---

## Operational Value

This implementation enables proactive monitoring of production workloads.

Instead of manually watching dashboards, operators receive immediate notification when CPU utilization exceeds safe operating thresholds and again when the system recovers.

This approach reduces mean time to detection (MTTD) and improves operational visibility.

---

## Lessons Learned

CloudWatch alarms evaluate metrics over time instead of reacting to individual spikes.

Using:

- 70% threshold
- 2 of 3 datapoints

helps reduce false positives while still detecting sustained resource utilization.

SNS enables automated notifications without requiring engineers to continuously monitor dashboards.

Testing alarms with controlled load generation provides confidence that monitoring behaves correctly before a production incident occurs.

---

## Evidence

Include screenshots for:

01-dashboard.png

Project Atlas Operations Dashboard

02-create-alarm.png

Alarm configuration

03-sns-topic.png

SNS Topic configuration

04-ok-email.png

OK notification

05-stress-command.png

Running stress utility

06-alarm-email.png

ALARM notification

07-cloudwatch-alarm.png

Alarm graph showing threshold exceeded

---

## Commands Used

Install stress

```bash
sudo apt update
sudo apt install stress
```

Determine CPU count

```bash
nproc
```

Generate CPU load

```bash
stress --cpu 2 --timeout 900
```

---

## Result

Successfully implemented proactive monitoring using Amazon CloudWatch and Amazon SNS.

The monitoring pipeline was validated end-to-end by generating CPU load, triggering automated alerts, and confirming recovery notifications.

Project Atlas now includes production-style observability with automated operational alerting.
