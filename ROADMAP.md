# RoadMap

Improvement ideas no specific order.

- ADD Terragrunt
- ADD compliance scanning
  - terrascan
  - tfsec

- ADD Logging
  - CloudWatch logging for storage
    - retention: 1yr
  - logrotate to contain disk usage
    - 1 day on the machine
    - no compressed archives

- Build base image using Packer
  - AMI configuration
  - Installed services
  - ready-to-go

- Name EBS volumes based on the game stored based on a pattern

```sh
# [game_name]-[version_from_vendor]-[4_character_random_string]-[counter]-[tf_deployment_random_string]
Satisfactory-update5-StDj-0-ux4b
KSP-2.3.7-DjSp-2-ux4b
SupremeCommander-7.5.4-CDJS-0-ux4b
```

- API Gateway + Lambda to start instance if stopped
  - Also, stop instance if no-one is connected for X minutes

- Address ignored tfsec and terrascan security best practices ignore/skips

- Create dev/prd ENVs via Terragrunt functionality
