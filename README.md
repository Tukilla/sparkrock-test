# Sparkrock DevOps Test – SaaS Escalation & Infrastructure Demo

## Introduction
This repository was created as part of the Sparkrock DevOps test.
It demonstrates the setup of a simplified SaaS-style environment on AWS, with emphasis on infrastructure-as-code, containerization, logging, and security practices.

All resources are deployed in a staging/test environment, clearly tagged with Environment=Staging to separate them from production workloads.

---

## Repository Structure
```plaintext
.
├── app
│   ├── api                 # Node.js API service
│   └── web                 # Nginx frontend
├── .github/workflows       # GitHub Actions workflow
├── docker-compose.yml      # Docker Compose stack for EC2
├── docs                    # Documentation and AWS screenshots
├── infrastructure
│   └── template.yaml       # CloudFormation template
├── README.md
├── sample.env              # Example environment variables
└── sync-logs.sh            # Script for syncing logs to S3
```
---

## Architecture
- CI/CD: GitHub Actions builds and pushes Docker images → Docker Hub
- Infrastructure: Provisioned via CloudFormation (infrastructure/template.yaml)
- Deployment: EC2 instance pulls images with docker-compose.yml
- Security: Nginx Basic Auth credentials externalized via .env (not committed to git)
- Logging: Nginx JSON logs mounted on EC2, synced to S3 via cron job
- Tagging: All AWS resources tagged with Environment=Staging and custom Name identifiers
- DNS: Managed via DigitalOcean, sparkrock-test.30hills.com points to AWS Elastic IP
- TLS: Certificates managed with Let’s Encrypt via Certbot

---

## Setup Instructions

Local Run:
```plaintext
1. Clone repo
2. docker compose up -d
```
AWS Deployment:
1. Provision infrastructure using infrastructure/template.yaml
2. Copy docker-compose.yml and .env to EC2 instance
3. Run:
   ```plaintext
   docker compose pull
   docker compose up -d
   ```
Authentication:
Authentication is externalized via .env (not committed to git).

Example .env:
```plaintext
BASIC_AUTH_USER=changeme
BASIC_AUTH_PASS=changeme
```
For reference, see sample.env.

On container startup, .htpasswd is automatically generated from these values.

---

## CI/CD Pipeline
The pipeline is implemented using GitHub Actions (.github/workflows/deploy.yml).

Steps:
1. Trigger – on push to main branch
2. Build – Docker images are built for:
   - tukilla/node-api:latest
   - tukilla/web-frontend:latest
3. Push – Images are pushed to Docker Hub
4. Deploy – GitHub Action connects to EC2 instance via SSH and runs:
   ```plaintext
   docker compose pull
   docker compose up -d
   ```
DNS Note:
Staging environment is exposed publicly via DigitalOcean DNS (sparkrock-test.30hills.com) pointing to AWS Elastic IP.
Certificates are managed with Certbot + Let’s Encrypt.

---

## Logging and Monitoring

Log Shipping to S3:
- Nginx access and error logs are written in JSON format (~/logs)
- Cron job executes sync-logs.sh every 5 minutes:
  ```plaintext
  */5 * * * * /home/ec2-user/sync-logs.sh >> /home/ec2-user/sync-logs.log 2>&1
  ```
- Logs are synced to S3 bucket:
- ```plaintext
  s3://sparkrock-logs-<account>-eu-north-1/nginx/
  ```
- Verified by accessing S3 and checking uploaded access.log and error.log

CloudWatch Alarm:
- Alarm name: Sparkrock-Staging-CPUAlarm
- Condition: CPUUtilization > 70% for 1 minute
- Defined in infrastructure/template.yaml
- Future extension: integrate with SNS for Slack/Email alerts

---

## Screenshots included in docs/:
- S3 bucket content
- EC2 instance with tags
- CloudFormation outputs
- Tag Editor view
- CloudWatch alarm configuration
- IAM for S3 bucket
- Security Groups

---

## Endpoints
- **Web:** [https://sparkrock-test.30hills.com/](https://sparkrock-test.30hills.com/)
- **API Health:** [https://sparkrock-test.30hills.com/api/health](https://sparkrock-test.30hills.com/api/health)
- **API Hello:** [https://sparkrock-test.30hills.com/api/hello](https://sparkrock-test.30hills.com/api/hello)

Test credentials (staging only):
```plaintext
Username: user
Password: admin123
```
---

## Notes
- CI/CD defined in .github/workflows/deploy.yml
- Docker images:
  - tukilla/node-api:latest
  - tukilla/web-frontend:latest
- Infrastructure tagged as Staging for cost and resource visibility

---

## Next Steps
- Extend monitoring with CloudWatch metrics and/or Dynatrace integration
- Replace single EC2 instance with an Auto Scaling Group
- Centralize logging (CloudWatch Logs or ELK pipeline)

