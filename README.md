# Game Server

## Infrastructure

- AWS
  - EC2 - computation
  - EBS - persistent storage
  - EIN - networking
  - Route53 - networking

- Terraform
  - Terraform Cloud for state storage
  - Terragrunt for IC code DRY
  - tfsec and terrascan for security best practice static analysis
  - infracost for cost controlling resources

## Services

| Name                 | Version  | Device  | Mount Point                 | System Service | Port               |
| -------------------- | -------- | ------- | --------------------------- | -------------- | ------------------ |
| Kerbal Space Program | 1.1.x    | nvme2n1 | /home/ubuntu/ksp            | yes            | 6702               |
| Satisfactory         | Update 5 | nvme1n1 | /home/ubuntu/.config/Epic   | yes            | 7777, 15000, 15777 |

## Additional Documentation

- [CHANGELOG.md](./CHANGELOG.md) - Published changes per version of each release
- [ROADMAP.md](./ROADMAP.md) - Ideas to implement
- [RUNBOOK.md](./RUNBOOK.md) - How-to execute actions
