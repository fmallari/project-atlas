# Ticket #004 – Configure Nginx Reverse Proxy

## Overview

Configured Nginx as a reverse proxy in front of Gunicorn to handle incoming HTTP traffic. Validated that requests were correctly forwarded while improving scalability and production readiness.

## Objectives

- Install Nginx
- Configure reverse proxy
- Enable site configuration
- Verify external connectivity

## Technologies

- Nginx
- Gunicorn
- HTTP
- Linux

## Evidence

### Nginx Service Status

Nginx was configured and verified as an active systemd service on the EC2 instance.

![Nginx service status](../../screenshots/Ticket-004/nginx-status.png)

### Reverse Proxy HTTP Validation

An HTTP request sent through Nginx returned `HTTP/1.1 200 OK`. The response identified Nginx as the public-facing server, confirming that requests were being accepted on port `80` and forwarded to Gunicorn.

![Nginx HTTP 200 response](../../screenshots/Ticket-004/nginx-http200.png)

### Browser Validation

The Flask application was successfully accessed through the EC2 instance's public HTTP endpoint without exposing port `5000` in the browser URL.

![Application accessed through Nginx](../../screenshots/Ticket-004/nginx-browser.png)

### Validation Result

The complete request path was validated:

```text
Client → Nginx port 80 → Gunicorn port 5000 → Flask application

## Outcome

Successfully exposed the Flask application through Nginx while separating web server responsibilities from the application server.# Ticket #004 – Configure Nginx Reverse Proxy

