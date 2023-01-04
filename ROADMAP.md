# RoadMap

Topics in a very loose order of priority.

## BizOps

- Patreon - Donations
- User pre-paid usage
  - Tiers w/ extras?
  - Alerts when < X hr remains
  - Pay for the title+resources(cpu,mem,storage,network) used
  - Free usage for high payers/regulars

## Infra/AWS/TF

ERROR:

- user-data.sh is over the 16k limit when base64 encoded for use by the instance. how to deal with this now?

OPTION:

- idea - effort to implement - effort up keep -

- user-data.sh reduced to curl'ing an install.sh from an S3 bucket, trigger the installer.sh - low - med <- For now solution
- Makes changes on-instance, create snapshot/AMI, document process in RUNBOOK.md - high - med-high
- Convert services to containers, run via buildah/containerd on EC2/ECS/EKS - high - med <- if we ever get funding
- Create Lambda to log into newly started instances and run process via Python/JS commands - med - med
- Ansible / Puppet - On instance start puppet agent reaches out to OpsWorks and runs commands as needed - high - low <- future enhancement

-----

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
- Convert IAM JSON to HCL

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
