# Ticket #005 – Application Incident Investigation

## Overview

Performed a structured production-style investigation of an intermittent application outage using Linux service management and web server logs. Collected evidence before making changes and verified overall application health.

## Objectives

- Inspect Gunicorn service
- Review system logs
- Analyze Nginx access logs
- Review Nginx error logs
- Confirm application availability

## Technologies

- journalctl
- systemctl
- Nginx
- Linux

## Outcome

Determined that the application and supporting infrastructure were operating normally. No service interruption or application failure was identified during the investigation.
