# Objective

Configure AWS Systems Manager (SSM) to securely manage the EC2 instance without requiring SSH access, enabling remote administration through Fleet Manager and Session Manager.

⸻

# Architecture 

Developer
      │
      ▼
AWS Systems Manager
      │
      ▼
Fleet Manager
      │
      ▼
Session Manager
      │
      ▼
EC2 Instance (project-atlas)

⸻

# Why This Matters

Instead of exposing SSH to the internet, AWS Systems Manager provides secure remote management using IAM authentication and encrypted connections.

Benefits include:

* No public SSH access required
* IAM-based authentication
* Session logging
* Audit trail
* Remote command execution
* Patch management
* Inventory management

⸻

# Implementation Steps

### Step 1 

Installed the Amazon SSM Agent 

snap list | grep amazon

### Step 2 

Verified the service 

sudo snap services amazon-ssm-agent

### Step 3 

Confirmed the EC2 Instance was using the correct IAM Role 

projectatlas-ec2role

### Step 4

Attached 

AmazonSSMManagedInstanceCore

### Step 5 

Verified IMDSv2 credentials 

TOKEN=$(curl -X PUT ...)

Retrieved: projectatlas-ec2role

### Step 6 

Verified connectivity to SSM endpoints 

curl -I https://ssm.us-east-2.amazonaws.com

curl -I https://ssmmessages.us-east-2.amazonaws.com

curl -I https://ec2messages.us-east-2.amazonaws.com

### Step 7 

Reviewed SSM Agent logs

Observed repeated pattern: AccessDeniedException

### Step 8 

Verified IAM policies.

Confirmed:

* AmazonSSMManagedInstanceCore
* CloudWatchAgentServerPolicy
* project-atlas-s3-access


### Step 9 

Restarted the SSM Agent 

sudo snap restart amazon-ssm-agent

### Step 10 

Verified successful registration 

Observed log entries: 

Registration attempted

Credentials ready

Worker started

### Step 11

Confirmed the EC2 instance appeared in Fleet Manager.

⸻

## Problem Encountered

This deserves its own section because it’s an excellent interview story.

Issue

The SSM Agent was running but the EC2 instance did not appear in Fleet Manager.

The logs contained repeated:

AccessDeniedException

ssm:UpdateInstanceInformation

## Investigation

Verified:

* IAM Role
* IAM Policies
* EC2 Metadata
* IMDSv2
* Network Connectivity
* SSM Endpoints
* Region
* Security Groups
* Instance Profile

⸻

## Root Cause

IAM permissions had not yet propagated completely to the running instance.

Restarting the SSM Agent forced it to refresh credentials and successfully register.

⸻

## Resolution

Restarted

Validation

* SSM Agent running
* Managed Node visible
* IAM Role verified
* Fleet Manager operational
* Session Manager operational
* No SSH required

⸻

## Lessons Learned

This section is gold.

Example:

Although the AmazonSSMManagedInstanceCore policy had already been attached to the EC2 IAM role, the running SSM Agent continued using stale credentials. Reviewing the logs identified repeated AccessDenied errors. Restarting the agent refreshed its credentials and completed registration with Systems Manager.

That sounds like someone who has worked on production systems.
