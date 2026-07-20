# Ticket #007 - Secure Application with HTTPS using Let's Encrypt

## Objective

Secure the production Flask application by configuring HTTPS using Let's Encrypt, Certbot, and Nginx. Ensure all traffic is encrypted and automatically redirected from HTTP to HTTPS.

---

## Technologies Used

- AWS EC2
- Ubuntu Linux
- Nginx
- Gunicorn
- Flask
- Certbot
- Let's Encrypt
- Namecheap DNS

---

## Architecture

Internet
        │
        ▼
francismallari.dev
        │
HTTPS (443)
        │
Let's Encrypt TLS Certificate
        │
Nginx
        │
Gunicorn
        │
Flask Application

---

## Implementation Steps

### 1. Configure DNS

Created the following DNS records:

- A Record
    - Host: @
    - Value: EC2 Public IP

- CNAME
    - Host: www
    - Value: francismallari.dev

---

### 2. Install Certbot

```bash
sudo apt update
sudo apt install certbot python3-certbot-nginx -y
```

---

### 3. Configure Nginx

Updated the Nginx server block:

```nginx
server_name francismallari.dev www.francismallari.dev;
```

---

### 4. Request TLS Certificate

```bash
sudo certbot --nginx \
  -d francismallari.dev \
  -d www.francismallari.dev
```

Certbot successfully:

- Requested certificate
- Validated domain ownership
- Installed the certificate
- Updated Nginx configuration
- Configured automatic renewal

---

### 5. Validate HTTPS

Verified:

- HTTPS loads successfully
- Browser trusts the certificate
- HTTP redirects to HTTPS
- Automatic renewal is configured

---

## Troubleshooting

### Issue

HTTPS requests timed out after the certificate was installed.

### Root Cause

AWS Security Group was missing an inbound rule for HTTPS (TCP 443).

### Resolution

Added an inbound rule:

- HTTPS
- TCP 443
- Source: 0.0.0.0/0

HTTPS immediately became accessible.

---

## Evidence

### DNS Records

![DNS Records](../screenshots/Ticket-007/dns-records.png)

---

### DNS Validation

![DNS Validation](../screenshots/Ticket-007/dns-validation.png)

---

### Certbot Installation

![Certbot Success](../screenshots/Ticket-007/certbot-success.png)

---

### Certificate Verification

![Certificate Details](../screenshots/Ticket-007/certificate-details.png)

---

### HTTPS Validation

![HTTPS Curl](../screenshots/Ticket-007/curl-https.png)

---

### Browser Verification

![HTTPS Browser](../screenshots/Ticket-007/https-browser.png)

---

## Lessons Learned

- DNS propagation can take time.
- Certbot automatically updates Nginx.
- HTTPS requires port 443 to be open in the AWS Security Group.
- Let's Encrypt certificates are valid for 90 days and can be renewed automatically.
- Nginx terminates TLS before forwarding requests to Gunicorn.

---

## Outcome

Successfully deployed a production-ready HTTPS-enabled Flask application using:

- AWS EC2
- Nginx
- Gunicorn
- Let's Encrypt
- Certbot

The application is securely accessible at:

https://francismallari.dev

and

https://www.francismallari.dev
