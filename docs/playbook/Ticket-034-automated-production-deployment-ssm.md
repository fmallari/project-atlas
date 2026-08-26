# Ticket 027 — Automated Production Deployment through AWS Systems Manager

## Objective

Extend the Project Atlas CI/CD pipeline so that a successful push to the `main`
branch can automatically deploy the new Docker image to the production EC2
instance without requiring an interactive SSH session.

The deployment path uses GitHub Actions, AWS IAM/OIDC, Amazon ECR, AWS Systems
Manager (SSM), EC2, Docker, and the existing Project Atlas deployment script.

---

## Architecture

Production deployment now follows this path:

Developer
    ↓
Git Push to main
    ↓
GitHub Actions
    ↓
Automated Tests
    ↓
Docker Build
    ↓
AWS Authentication via OIDC
    ↓
Amazon ECR
    ↓
AWS Systems Manager SendCommand
    ↓
EC2
    ↓
deploy-project-atlas.sh
    ↓
Docker Container
    ↓
Gunicorn
    ↓
Nginx
    ↓
francismallari.dev

SSH is not required for the GitHub Actions deployment path.

---

## Implementation

### 1. Enabled AWS Systems Manager on EC2

The EC2 instance already contained the Amazon SSM Agent as a Snap package.

The instance IAM role was updated through Terraform to attach:

`AmazonSSMManagedInstanceCore`

This allows the EC2 instance to register with and communicate with AWS Systems
Manager.

SSM connectivity was verified from an administrative workstation using:

```bash
aws ssm describe-instance-information \
  --region us-east-2
```

The Project Atlas instance reported:

* PingStatus: Online
* Platform: Ubuntu
* SSM Agent: 3.3.4793.0

---

### 2. Added GitHub Actions SSM permissions

The IAM role assumed by GitHub Actions was extended with permissions required
to initiate and inspect deployment commands.

Required actions included:

* ssm:SendCommand
* ssm:GetCommandInvocation
* ssm:ListCommandInvocations

SendCommand was scoped to the Project Atlas EC2 instance and the
AWS-RunShellScript SSM document.

Terraform remained the source of truth for these IAM changes.

---

### 3. Verified SSM remote command execution

Before modifying the production workflow, SSM was tested independently.

A test command was sent to the Project Atlas EC2 instance using:

```bash
aws ssm send-command \
  --region us-east-2 \
  --instance-ids <INSTANCE_ID> \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["echo Project Atlas SSM deployment test","hostname","date"]'
```

The resulting command invocation returned:

```text
Status: Success
```

with a response code of:

```text
0
```

This confirmed that Systems Manager could remotely execute commands on the
production EC2 instance.

---

### 4. Extended the GitHub Actions pipeline

The existing CI workflow already:

1. Checked out the repository
2. Configured Python
3. Installed dependencies
4. Ran automated tests
5. Built the Docker image
6. Authenticated to AWS
7. Logged into Amazon ECR
8. Tagged and pushed the image to ECR

The workflow was extended with two additional production stages:

* Deploy to EC2 through SSM
* Wait for production deployment

After the image is pushed to ECR, GitHub Actions sends an SSM command instructing
EC2 to execute:

```bash
sudo /usr/local/bin/deploy-project-atlas.sh <GIT_COMMIT_SHA>
```

The Git commit SHA is also used as the Docker image tag, connecting the deployed
production artifact directly to the source revision that created it.

---

### 5. Deployment status verification

GitHub Actions captures the SSM Command ID and polls:

```bash
aws ssm get-command-invocation
```

until the remote deployment reaches a terminal state.

Successful deployments return:
```text
Success
```
Failed, cancelled, or timed-out deployments cause the GitHub Actions workflow
to fail and expose the SSM command output for troubleshooting.

This prevents the CI/CD workflow from reporting success merely because the
remote deployment command was submitted.

---

## Troubleshooting

Several issues were discovered while implementing the deployment path.

SSM Agent service not found through systemd

Running:
```bash
systemctl status amazon-ssm-agent
```

reported that the service could not be found.

Investigation showed that Amazon SSM Agent was installed through Snap.

The correct verification command was:

```bash
sudo snap services amazon-ssm-agent
```

which confirmed that the agent was enabled and active. 

## AccessDenied when querying SSM from EC2 

Running: 

```bash
aws ssm describe-instance-information
```

from the EC2 instance returned AccessDeniedException.

This did not mean the SSM agent was broken.

The command was being executed using the EC2 instance IAM role, which did not
have permission to call the SSM administrative DescribeInstanceInformation
API.

Running the verification from an authorized administrative workstation
successfully showed the instance as Online.

This reinforced the distinction between:

* permissions required by the SSM agent on EC2
* permissions required by an operator or CI/CD system to control SSM

## IAM permissions

The GitHub Actions IAM role originally supported ECR operations but did not
have the permissions necessary to deploy through Systems Manager.

Terraform was updated to grant only the SSM operations required by the
deployment workflow.

---

## Validation

A push to main successfully executed the complete GitHub Actions workflow.

The pipeline completed:

* Checkout repository — Success
* Set up Python — Success
* Install dependencies — Success
* Run automated tests — Success
* Build Docker image — Success
* Configure AWS credentials — Success
* Login to Amazon ECR — Success
* Tag and push image to ECR — Success
* Deploy to EC2 through SSM — Success
* Wait for production deployment — Success

The complete workflow finished successfully in approximately 54 seconds.

---

## Result 

Project Atlas now supports an automated production deployment path: 

```text 
git push
   ↓
GitHub Actions
   ↓
Tests
   ↓
Docker Build
   ↓
ECR
   ↓
AWS SSM
   ↓
EC2
   ↓
Validated Production Deployment
```

Production deployment no longer requires GitHub Actions to SSH into the EC2
instance.

The workflow also waits for the remote deployment result instead of treating
successful command submission as successful application deployment.

---

## Key Lessons 

### Authentication and autorization are separate 

An AWS workload may successfully assume an IAM role while still receiving
AccessDenied for an individual API operation. The effective IAM policy must
explicitly authorize the requested action.

### SSM separates remote management from SSH

AWS Systems Manager provides a managed control plane for executing deployment
commands on EC2 without exposing SSH credentials to the CI/CD workflow.

### CI/CD should verify deployment completion 

Successfully building and pushing an image does not prove that production was
updated successfully.

The pipeline now observes the SSM command until deployment succeeds or fails.

### Infrastructure should remain reproducible 

IAM permissions and SSM configuration were managed through Terraform rather
than relying on undocumented console changes.

### Immutable image tags improve traceability

Using the Git commit SHA as the Docker image tag makes it possible to connect a
production container to the exact source revision that produced it.

---

## Technologies

* AWS EC2
* AWS Systems Manager
* AWS IAM
* AWS STS / OIDC
* Amazon ECR
* Terraform
* GitHub Actions
* Docker
* Bash
* Gunicorn
* Nginx 
