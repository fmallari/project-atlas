# Ticket 026 — EC2 Disk Capacity Incident & Recovery

## Objective

Investigate and recover an AWS EC2 host after filesystem
capacity exhaustion prevented application files from being written.

## Incident Summary

While deploying an updated portfolio homepage to the Project Atlas
Flask application, Nano failed to save the new template.

Initial investigation showed the EC2 root filesystem had reached
100% utilization with no available disk capacity.

## Impact

- New application files could not be written.
- Homepage deployment was blocked.
- Application stability was at risk if services required additional
  filesystem writes.
- Existing production traffic remained available during investigation.

## Detection

The incident was first observed when Nano returned a disk-space warning
while attempting to save:

templates/index.html

Disk utilization was verified with:

df -h

Result:

/dev/root
6.7G total
6.6G used
0 available
100% utilization

## Investigation

### Filesystem Capacity

df -h /

Confirmed root filesystem exhaustion.

### Inode Utilization

df -i

Inode utilization was approximately 21%, ruling out inode exhaustion.

### Log Utilization

sudo journalctl --disk-usage

System journals consumed approximately 39.9 MB, ruling out excessive
journald growth as the primary cause.

### Home Directory Analysis

du -h --max-depth=1 ~ | sort -h

The investigation identified:

~/.vscode-server     ~1.4 GB
~/backups            ~354 MB
~/project-atlas      ~90 MB
~/.cache             ~21 MB

Further inspection showed the majority of VS Code Remote storage was
located in:

~/.vscode-server/bin
~/.vscode-server/cli

## Root Cause

VS Code Remote Server artifacts had accumulated approximately 1.4 GB
of storage on a small EC2 root volume.

This contributed significantly to filesystem capacity exhaustion.

## Remediation

Removed the VS Code Remote Server installation:

rm -rf ~/.vscode-server

VS Code Remote can reinstall these server-side components when needed,
making them safe to remove during recovery.

## Recovery Validation

After cleanup:

/dev/root
6.7G total
5.3G used
1.4G available
80% utilization

Approximately 1.4 GB of filesystem capacity was recovered.

Gunicorn was restarted and verified:

systemctl status gunicorn

Application validation:

curl -I http://127.0.0.1:5000
HTTP/1.1 200 OK

curl http://127.0.0.1:5000/health
status: healthy

Production validation:

curl -I https://francismallari.dev
HTTP/1.1 200 OK

curl https://francismallari.dev/health
status: healthy

## Resolution

Filesystem capacity was restored and the Project Atlas application
successfully deployed the new Cloud Engineer / SRE portfolio homepage.

The full production request path was validated:

Client
  ↓
HTTPS
  ↓
Nginx
  ↓
Gunicorn
  ↓
Flask
  ↓
Application

## Lessons Learned

1. Disk capacity is a production reliability concern, not simply a
   server-maintenance concern.

2. Filesystem capacity and inode exhaustion should be investigated
   independently.

3. Large development-tool artifacts can consume meaningful capacity
   on small cloud instances.

4. Disk utilization should be monitored proactively rather than
   discovered when writes begin failing.

5. Recovery should include application-level validation, not only
   filesystem validation.

6. Monitoring infrastructure can itself be affected by the failure it
   is intended to observe. Disk-capacity monitoring should therefore
   alert before filesystem exhaustion begins disrupting telemetry.

## Follow-Up Actions

- Add disk utilization monitoring to CloudWatch.
- Configure an alert threshold for filesystem utilization.
- Review backup retention.
- Remove obsolete application services.
- Consider expanding the EC2 root EBS volume.
- Document disk-capacity troubleshooting in the operations runbook.

## Engineering Skills Demonstrated

- Linux filesystem troubleshooting
- AWS EC2 operations
- Production incident response
- Root-cause analysis
- Capacity management
- Gunicorn service management
- Nginx reverse-proxy validation
- HTTP/HTTPS troubleshooting
- Application health validation
- Operational documentation

### CloudWatch Agent Impact

Reviewing the CloudWatch Agent logs revealed repeated errors:

> Error happened when saving state file ... no space left on device

The agent was unable to persist state associated with the Nginx access
log while the root filesystem was exhausted.

This demonstrated that the incident affected not only application
deployment operations but also the observability layer responsible for
shipping application and Nginx logs to CloudWatch.

## Preventive Action — Disk Capacity Alerting

Post-incident review confirmed that Project Atlas was already
collecting `disk_used_percent` through the CloudWatch Agent.

The observability gap was therefore not metric collection, but the
absence of proactive alerting.

A CloudWatch alarm was created with the following configuration:

- Namespace: `ProjectAtlas`
- Metric: `disk_used_percent`
- Filesystem: `/`
- Statistic: Average
- Evaluation period: 1 minute
- Threshold: > 85%
- Evaluation: 3 of 3 datapoints
- Notification target: `project-atlas-alerts`
- Alarm: `ProjectAtlas-High-Disk-Usage`

This provides early warning of filesystem capacity pressure before
the instance reaches full disk exhaustion.

### Reliability Improvement

Before:

Disk usage → 100% → filesystem writes fail → manual detection

After:

Disk usage → 85% threshold → CloudWatch alarm → notification →
operator intervention before exhaustion

## Final Outcome

The incident was successfully resolved after approximately 1.4 GB of
disk capacity was reclaimed from unnecessary VS Code Remote Server
artifacts.

Post-recovery validation confirmed:

- Root filesystem utilization reduced from 100% to approximately 80%
- Gunicorn returned to a healthy running state
- Local application endpoint returned HTTP 200
- `/health` returned a healthy application status
- Public HTTPS traffic through Nginx returned HTTP 200
- CloudWatch Agent log collection resumed
- `francismallari.dev` successfully served the updated portfolio homepage

A post-incident review determined that disk utilization telemetry was
already being collected through the CloudWatch Agent, but no proactive
alarm existed.

`ProjectAtlas-High-Disk-Usage` was therefore created to alert when root
filesystem utilization exceeds 85% for 2 of 3 one-minute datapoints.

The incident progressed Project Atlas from reactive disk-capacity
recovery to proactive capacity monitoring and alerting.
