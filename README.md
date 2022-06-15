# Game Server

## Infrastructure

- AWS
  - EC2, EBS, EIN, Route53
- Terraform
  - Terraform Cloud for state storage
  - Terragrunt for IC code DRY

## Services

|              |          |         |                           |                |       |
| ------------ | -------- | ------- | ------------------------- | -------------- | ----- |
| Name         | Version  | Device  | Mount Point               | System Service | Port  |
| Satisfactory | Update 6 | nvme1n1 | /home/ubuntu/.config/Epic | yes            | 15777 |

## Version

0.0.6

- Set Satisfactory to `beta` (Stable) branch in place of `experimental`
