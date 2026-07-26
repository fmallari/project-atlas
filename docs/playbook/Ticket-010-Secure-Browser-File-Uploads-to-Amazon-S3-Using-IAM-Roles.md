Ticket 010 – Secure Browser File Uploads to Amazon S3 Using IAM Roles

Objective

Replace EC2 local file storage with Amazon S3 using IAM Roles and temporary AWS credentials.

Technologies

* Flask
* Amazon S3
* boto3
* IAM Roles
* STS
* Nginx
* Gunicorn
* Python virtual environments

Key Features

* Browser-based file uploads
* UUID-based object naming
* secure_filename() sanitization
* Upload size limits
* IAM Role authentication (no access keys)
* Reusable S3 service layer
* Private encrypted S3 bucket

Validation

* Browser upload completed successfully
* Object verified in S3
* Object downloaded from S3 using AWS CLI
* End-to-end upload pipeline validated

Production Incidents Resolved

* 502 Bad Gateway caused by missing boto3 in the virtual environment
* 413 Request Entity Too Large caused by the default Nginx upload limit
