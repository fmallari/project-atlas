# Ticket 032 — Container Resilience & Automatic Recovery

## Objective

Improve the reliability of the Project Atlas production deployment by configuring the Docker container to recover automatically from application failure and EC2 instance reboots.

The goal was to eliminate dependence on manually starting the application after a container failure or host restart.

---

## Architecture

Production request path:

Internet
→ HTTPS
→ Nginx
→ 127.0.0.1:8080
→ Docker
→ Gunicorn
→ Flask / Project Atlas

The previous host-based Gunicorn service was disabled after validating the containerized production deployment.

---

## Implementation

A systemd service was created to manage the Project Atlas Docker container:

`/etc/systemd/system/project-atlas-container.service`

Key configuration:

```ini
[Unit]
Description=Project Atlas Docker Container
Requires=docker.service
After=docker.service network-online.target
Wants=network-online.target

[Service]
Type=simple
Restart=always
RestartSec=5

ExecStart=/usr/bin/docker start -a project-atlas-container
ExecStop=/usr/bin/docker stop -t 10 project-atlas-container

[Install]
WantedBy=multi-user.target
