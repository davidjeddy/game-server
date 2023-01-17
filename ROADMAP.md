# RoadMap

Topics in a very loose order of priority.

## Next

- Intall process for services we have archives for
- Fix DLM policy and permissions to enable daily backup snapshots
- Remove default VPC via Cloud Posse provider resource
- Dump SSH, replace with SSM
- Convert IAM JSON to HCL

## BizOps

- Patreon - Donations
- User pre-paid usage
  - Tiers w/ extras?
  - Alerts when < X hr remains
  - Pay for the title+resources(cpu,mem,storage,network) used
  - Free usage for high payers/regulars

## Infra/AWS/TF

- Load balancer in front of EC2 instances for better traffic and routing management
  - Bastion host for non application ingress - why did we want this?
- API Gateway + Lambda to start instance if stopped
  - Also, stop instance if no-one is connected for X minutes
- ADD Logging
  - CloudWatch logging for storage
    - retention: 1yr
  - logrotate to contain disk usage
    - 1 day on the machine
    - no compressed archives

## OS / system

- Add `fail2ban` OS package as the instance is public facing
- Services should be Terraform modules
  - Move EBS/KMS/Secret/SG/etc
  - Split installer.sh into segments isolated in TF modules
    - merge and output via root TF module
    - Different Linux users per service
- Iterate on resources and config logic the reduce duplication; DRY it out
