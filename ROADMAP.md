# RoadMap

Topics in a very loose order of priority.

## Infra/AWS/TF

FIX: user-data.sh is over the 16k limit, how to deal with this now?

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
- Fix DLM policy and permissions to enable daily backup snapshots
- Remove default VPC via Cloud Posse provider resource
- Dump SSH, replace with SSM

## OS / system

- Add `fail2ban` OS package as the instance is public facing

- Services should be Terraform modules
  - Move EBS/KMS/Secret/SG/etc
  - Split user-data.sh into segments isolated in TF modules
    - merge and output via root TF module
    - Different Linux users per service
- Iterate on resources and config logic the reduce duplication; DRY it out

## Services

- Can KSP : DMP vessels be recovered?
