# RoadMap

Topics in a very loose order of priority.

## Infra/AWS/TF

- Generate SSH key pair for EC2 instance at creation, not manually
- Load balancer in front of EC2 instances for better traffic and routing management
  - Bastion host for non application ingress
- API Gateway + Lambda to start instance if stopped
  - Also, stop instance if no-one is connected for X minutes
- ADD Logging
  - CloudWatch logging for storage
    - retention: 1yr
  - logrotate to contain disk usage
    - 1 day on the machine
    - no compressed archives
- Build base image using Packer
  - system packages
  - shared resources (steamcmd/golang)

## OS / system

- Add `fail2ban` OS package as the instance is public facing

- Services should be Terraform modules
  - Move EBS/KMS/Secret/SG/etc
  - Split user-data.sh into segments isolated in TF modules
    - merge and output via root TF module
    - Different Linux users per service

## Services

- Can KSP : DMP vessels be recovered?
