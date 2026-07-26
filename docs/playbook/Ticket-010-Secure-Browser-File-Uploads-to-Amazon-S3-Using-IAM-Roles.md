# Ticket 010 – Secure Browser File Uploads to Amazon S3 Using IAM Roles

## Objective

Design and implement a secure file upload pipeline that stores browser-uploaded files in Amazon S3 using IAM Roles and temporary AWS credentials. The objective was to replace local EC2 storage with durable object storage while following cloud security best practices.

---

## Background

Initially, uploaded files would have been stored on the EC2 instance.

This approach introduces several problems:

- EC2 instances are ephemeral and can be terminated or replaced.
- Files stored locally are not shared across multiple application instances.
- Auto Scaling environments require shared storage.
- Local storage increases operational risk and complicates backups.

Amazon S3 provides durable, highly available object storage that decouples application compute from persistent storage.

To avoid storing AWS access keys on the server, Project Atlas authenticates to S3 using an EC2 IAM Role with temporary credentials provided by AWS Security Token Service (STS).

---

## Architecture

```text
                     User Browser
                          │
                          ▼
                  Nginx Reverse Proxy
                          │
                          ▼
                  Gunicorn WSGI Server
                          │
                          ▼
                  Flask Application
                          │
                          ▼
               services/s3_service.py
                          │
                          ▼
                        boto3
                          │
                          ▼
             IAM Role (Temporary STS Credentials)
                          │
                          ▼
                  Amazon S3 Bucket
```

---

## Technologies Used

### AWS

- Amazon EC2
- Amazon S3
- IAM Policies
- IAM Roles
- AWS STS

### Python

- Flask
- boto3
- Werkzeug (`secure_filename`)
- uuid

### Linux

- Ubuntu 24.04 LTS
- Gunicorn
- Nginx

---

## Security Design

Several security best practices were implemented during this ticket.

### IAM Roles

The application authenticates using an EC2 IAM Role instead of long-lived AWS access keys.

Benefits:

- No credentials stored on disk.
- Temporary credentials managed by AWS STS.
- Automatic credential rotation.
- Reduced risk of credential exposure.

### Least Privilege

A custom IAM policy grants only the permissions required by the application:

- `s3:ListBucket`
- `s3:GetObject`
- `s3:PutObject`
- `s3:DeleteObject`

Permissions are restricted to the Project Atlas S3 bucket.

### Secure File Names

Uploaded filenames are sanitized using `secure_filename()`.

UUIDs are generated to ensure every uploaded object receives a unique name, preventing accidental overwrites.

---

## Implementation

### Step 1

Created a private Amazon S3 bucket with:

- Block Public Access enabled
- Server-side encryption (SSE-S3)
- Bucket owner enforced
- Versioning disabled

### Step 2

Created a custom IAM policy granting least-privilege S3 access.

### Step 3

Created and attached an EC2 IAM Role.

Validated temporary credentials using:

```bash
aws sts get-caller-identity
```

### Step 4

Built a reusable S3 service layer.

```
services/
└── s3_service.py
```

This separates AWS interaction from Flask route logic.

### Step 5

Created a browser upload endpoint.

```
GET /upload
POST /upload
```

The upload route:

- receives the uploaded file
- validates the filename
- sanitizes the filename
- generates a UUID
- uploads the object to S3

### Step 6

Validated successful uploads using:

- Browser
- AWS CLI
- Download verification

---

## Validation

The implementation was validated using multiple methods.

### Browser Upload

Uploaded files successfully through the Flask web interface.

### AWS CLI

```bash
aws s3 ls s3://project-atlas-fmallari/uploads/
```

Confirmed uploaded objects exist.

### Download Validation

```bash
aws s3 cp s3://project-atlas-fmallari/uploads/<filename> downloaded-file
```

Successfully downloaded the uploaded object, confirming end-to-end functionality.

---

## Production Incidents

### Incident 1 – 502 Bad Gateway

#### Symptoms

Nginx returned:

```
502 Bad Gateway
```

#### Root Cause

`boto3` had been installed into the system Python instead of the project's virtual environment.

Gunicorn failed to import the dependency during application startup.

#### Resolution

Activated the project virtual environment.

Installed:

```bash
pip install boto3
```

Updated:

```bash
pip freeze > requirements.txt
```

Restarted Gunicorn.

---

### Incident 2 – 413 Request Entity Too Large

#### Symptoms

Browser upload returned:

```
413 Request Entity Too Large
```

#### Root Cause

Nginx rejected the upload because the default request size limit was exceeded.

#### Resolution

Updated the Nginx configuration:

```nginx
client_max_body_size 10M;
```

Validated configuration:

```bash
sudo nginx -t
```

Reloaded Nginx.

---

## Lessons Learned

This ticket reinforced several cloud engineering principles.

- Stateless applications should not rely on local EC2 storage.
- IAM Roles eliminate the need for long-lived AWS credentials.
- A service layer improves code organization and maintainability.
- UUIDs prevent accidental filename collisions.
- Virtual environment dependencies must match the application runtime.
- Reverse proxies may reject requests before they reach the application.

---

## Evidence

Suggested screenshots:

1. Amazon S3 bucket
2. IAM policy
3. IAM role
4. STS validation
5. Upload page
6. Successful upload
7. S3 object listing
8. UUID filename upload
9. Download validation
10. 502 incident
11. 413 incident

---

## Commands Used

```bash
aws sts get-caller-identity

aws s3 ls s3://project-atlas-fmallari

aws s3 cp ...

pip install boto3

pip freeze > requirements.txt

sudo nginx -t

sudo systemctl reload nginx

sudo systemctl restart gunicorn
```

---

## Skills Demonstrated

### AWS

- Amazon S3
- IAM Roles
- IAM Policies
- STS

### Python

- Flask
- boto3
- Service Layer Architecture
- Secure File Uploads
- UUID Generation

### Linux

- Gunicorn
- Nginx
- Python Virtual Environments

### Operations

- Production Troubleshooting
- Root Cause Analysis
- Validation Testing
- Secure Configuration

---

## Next Steps

Ticket 011 – Centralized Application Logging with Amazon CloudWatch
