# Ticket 009 – Production Incident Response: Diagnosing and Resolving a 502 Bad Gateway

## Objective

Investigate and resolve a production outage that resulted in users receiving a **502 Bad Gateway** error when accessing the Project Atlas application. The goal was to restore service by identifying the failing component, determining the root cause, and validating the fix using a structured troubleshooting approach.

---

## Background

Project Atlas is deployed on an AWS EC2 instance using the following stack:

- Ubuntu 24.04 LTS
- Nginx as the reverse proxy
- Gunicorn as the WSGI application server
- Flask as the web application

When users attempted to access the application, Nginx returned a **502 Bad Gateway** error, indicating it could not communicate with the upstream application server.

Rather than immediately restarting services, this ticket focused on following a production-style incident response process to isolate the failure.

---

## Architecture

```text
                Internet
                    │
                    ▼
              Nginx Reverse Proxy
                    │
                    ▼
            Gunicorn WSGI Server
                    │
                    ▼
             Flask Application
```

The request must successfully pass through each layer. A failure at any point prevents the application from responding.

---

## Technologies Used

### AWS

- Amazon EC2

### Linux

- Ubuntu 24.04 LTS
- systemd
- journalctl

### Web Stack

- Nginx
- Gunicorn
- Flask

### Validation Tools

- curl
- systemctl
- journalctl

---

## Symptoms

The application became inaccessible and displayed:

```text
502 Bad Gateway
nginx/1.28.3
```

This indicated that Nginx was running but was unable to successfully communicate with Gunicorn.

---

## Investigation

Instead of guessing, the issue was investigated layer by layer.

### Step 1 — Verify Nginx

Checked that the reverse proxy service was running.

```bash
sudo systemctl status nginx
```

Result:

- Nginx active
- No configuration errors

---

### Step 2 — Verify Gunicorn

Checked Gunicorn service status.

```bash
sudo systemctl status gunicorn
```

Result:

- Gunicorn failed to start successfully.

---

### Step 3 — Review Application Logs

Reviewed Gunicorn logs.

```bash
sudo journalctl -u gunicorn -n 50 --no-pager
```

The logs showed that Gunicorn workers failed during application startup.

---

### Step 4 — Validate the Application

Verified the Flask application locally using curl.

```bash
curl http://127.0.0.1:5000
```

This confirmed the upstream application was unavailable.

---

## Root Cause

Gunicorn workers were unable to complete application startup, preventing Nginx from forwarding requests to the Flask application.

Because the upstream application never became available, Nginx returned a **502 Bad Gateway** response.

---

## Resolution

After identifying the application startup issue, the configuration was corrected and Gunicorn was restarted.

```bash
sudo systemctl restart gunicorn
```

Service status was verified:

```bash
sudo systemctl status gunicorn
```

Once Gunicorn successfully started, Nginx was again able to proxy requests to Flask.

---

## Validation

Application availability was verified using multiple methods.

Browser:

- Application loaded successfully.

Health endpoint:

```bash
curl http://127.0.0.1:5000/health
```

Public endpoint:

```bash
curl https://francismallari.dev/health
```

Gunicorn:

```bash
sudo systemctl status gunicorn
```

Nginx:

```bash
sudo systemctl status nginx
```

All validation checks confirmed that production service had been restored.

---

## Lessons Learned

This incident reinforced several important operational principles.

- Troubleshoot one layer at a time instead of making assumptions.
- A 502 Bad Gateway does not necessarily indicate an Nginx problem.
- Always review application logs before restarting services.
- Validate fixes using both local and public endpoints.
- Structured troubleshooting reduces recovery time.

---

## Production Takeaways

Production incident response is a methodical process rather than trial and error.

A useful troubleshooting model is:

```text
Internet
    ↓
Nginx
    ↓
Gunicorn
    ↓
Flask
```

Determining which layer is failing dramatically reduces investigation time.

---

## Evidence

Include screenshots of:

- 502 Bad Gateway page
- Gunicorn status
- Gunicorn logs
- Successful service recovery
- Health endpoint validation

---

## Commands Used

```bash
sudo systemctl status nginx

sudo systemctl status gunicorn

sudo journalctl -u gunicorn -n 50 --no-pager

curl http://127.0.0.1:5000

curl https://francismallari.dev/health

sudo systemctl restart gunicorn
```

---

## Skills Demonstrated

### Cloud

- Amazon EC2

### Linux

- systemd
- journalctl
- Service management

### Operations

- Incident response
- Root cause analysis
- Production troubleshooting
- Layered debugging
- Validation testing

---

## Next Steps

Ticket 010 – Secure Browser File Uploads to Amazon S3 Using IAM Roles
