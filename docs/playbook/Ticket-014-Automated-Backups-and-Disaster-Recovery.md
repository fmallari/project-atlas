# Ticket 014 — Automated Backups and Disaster Recovery

## Sprint

Sprint 4 — Resilience

## Objective

Create and validate an automated backup workflow for Project Atlas using Linux shell scripting, compressed archives, and cron scheduling.

The goal is to reduce recovery risk by ensuring critical application files are backed up automatically and can be inspected before a restore is attempted.

## Background

Project Atlas previously depended on the files stored directly on a single EC2 instance.

If the instance were corrupted, accidentally deleted, or became inaccessible, application recovery would require manually reconstructing the project from GitHub and reconfiguring the environment.

This ticket introduces a repeatable backup process and establishes the foundation for disaster recovery.

## Architecture

```text
Project Atlas EC2 Instance
        │
        ▼
Backup Shell Script
        │
        ▼
Compressed tar.gz Archive
        │
        ▼
Local Backup Directory
        │
        ▼
Cron Scheduler
        │
        ▼
Nightly Automated Backup
```

## Technologies Used

- Amazon EC2
- Ubuntu Linux
- Bash
- tar
- gzip
- cron
- Git
- GitHub

## Assets Backed Up

The initial backup includes the complete Project Atlas repository:

- Flask application files
- Templates
- Services
- Documentation
- Architecture files
- Screenshots
- README
- Dependency definitions

The initial version also includes generated or reproducible content such as:

- `venv/`
- `__pycache__/`
- `.git/`

These will be excluded in a later refinement to reduce archive size and keep backups focused on recoverable source and configuration files.

## Implementation

### 1. Created a Backup Directory

```bash
mkdir -p ~/backups
```

### 2. Created the Backup Script

Created:

```text
/home/ubuntu/backup-project-atlas.sh
```

Script:

```bash
#!/bin/bash

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_DIR="$HOME/backups"
ARCHIVE="project-atlas-$TIMESTAMP.tar.gz"

echo "Creating backup..."

tar -czf "$BACKUP_DIR/$ARCHIVE" \
    "$HOME/project-atlas"

echo "Backup created: $ARCHIVE"
```

### 3. Made the Script Executable

```bash
chmod +x ~/backup-project-atlas.sh
```

### 4. Ran the Backup Manually

```bash
~/backup-project-atlas.sh
```

Observed output:

```text
Creating backup...
Backup created: project-atlas-2026-07-31_23-51-38.tar.gz
```

### 5. Verified the Archive Exists

```bash
ls -lh ~/backups
```

### 6. Inspected Archive Contents

```bash
tar -tzf ~/backups/project-atlas-2026-07-31_23-51-38.tar.gz | head -20
```

The archive preserved the expected Project Atlas directory structure and included application files, screenshots, documentation, and supporting directories.

### 7. Scheduled Nightly Backups with Cron

Opened the user crontab:

```bash
crontab -e
```

Added:

```cron
0 2 * * * /home/ubuntu/backup-project-atlas.sh >> /home/ubuntu/backups/backup.log 2>&1
```

This runs the backup every day at 2:00 AM using the EC2 instance's system timezone.

### 8. Verified the Cron Entry

```bash
crontab -l
```

Confirmed the nightly schedule was installed successfully.

## Validation

The implementation was considered successful after confirming:

- Backup directory created
- Script executed successfully
- Timestamped archive generated
- Archive could be opened and listed
- Project directory structure was preserved
- Cron entry was installed
- Standard output and errors were redirected to `backup.log`

## Operational Observations

The first archive inspection showed that generated directories such as `__pycache__` were included.

This does not prevent recovery, but it increases archive size and stores files that can be recreated. A future improvement will add exclusions for:

```text
venv/
__pycache__/
.git/
.pytest_cache/
*.pyc
```

The `tar` message:

```text
Removing leading '/' from member names
```

was expected behavior. It prevents the archive from restoring files using absolute filesystem paths and makes extraction safer.

## Cron Schedule

```cron
0 2 * * *
```

Meaning:

- Minute: `0`
- Hour: `2`
- Day of month: every day
- Month: every month
- Day of week: every day

The job runs nightly at 2:00 AM according to the server's timezone.

## Disaster-Recovery Value

This implementation provides a repeatable copy of the Project Atlas application files.

It reduces reliance on manual reconstruction and creates the foundation for a documented restore process.

The current backup remains on the same EC2 instance, so it does not yet protect against complete instance loss. The next resilience improvement will upload archives to Amazon S3 and validate a restore from remote storage.

## Lessons Learned

- A backup should be inspected, not merely created.
- Timestamped filenames preserve historical recovery points.
- Cron removes dependency on manual execution.
- Backup logs make scheduled failures easier to investigate.
- Reproducible files should be excluded to reduce backup size.
- A local-only backup does not protect against full instance loss.
- A backup that has never been restored is not fully validated.

## Operational Takeaways

- Automation improves consistency and reduces missed backups.
- Archive integrity should be checked regularly.
- Backup retention and cleanup policies are necessary to prevent disk exhaustion.
- Off-instance storage is required for meaningful disaster recovery.
- Restore testing should be part of the backup lifecycle.

## Skills Demonstrated

### Linux Administration

- Bash scripting
- File permissions
- Archive creation
- Cron scheduling
- Output redirection

### Cloud and Reliability Engineering

- Backup planning
- Recovery-point creation
- Operational automation
- Disaster-recovery preparation
- Validation and evidence collection

### Operations

- Scheduled maintenance tasks
- Backup logging
- Archive inspection
- Risk identification
- Recovery planning

## Evidence

Recommended files:

```text
screenshots/Ticket-014/
├── 01-backup-script-created.png
├── 02-backup-archive-created.png
├── 03-backup-archive-contents.png
├── 04-backup-archive-size.png
├── 05-crontab-configured.png
└── 06-cron-service-running.png
```

## Commands Used

```bash
mkdir -p ~/backups

nano ~/backup-project-atlas.sh

chmod +x ~/backup-project-atlas.sh

~/backup-project-atlas.sh

ls -lh ~/backups

tar -tzf ~/backups/project-atlas-2026-07-31_23-51-38.tar.gz | head -20

crontab -e

crontab -l

systemctl status cron
```

## Result

Project Atlas now has a functioning nightly backup process that creates timestamped compressed archives and records scheduled execution output.

This establishes the first layer of the project's disaster-recovery strategy.

## Next Steps

- Exclude `venv`, `.git`, `__pycache__`, and temporary files
- Upload backups automatically to Amazon S3
- Add backup retention and deletion rules
- Generate checksums for integrity verification
- Perform a controlled restore test
- Document a full disaster-recovery runbook
