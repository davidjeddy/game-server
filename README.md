# Game Server

## Infrastructure

- [AWS](https://aws.amazon.com)
  - EC2 - computation
  - EBS - persistent storage
  - EIN - networking
  - Route53 - networking

- [Terraform](https://www.terraform.io/)
  - [infracost](https://www.infracost.io/) for cost controlling resources
  - [Terraform Cloud](https://cloud.hashicorp.com/products/terraform) for state storage
  - [Terragrunt](https://terragrunt.gruntwork.io/) for IC code DRY
  - [tfsec](https://github.com/aquasecurity/tfsec) and [terrascan](https://github.com/tenable/terrascan) for security best practice static analysis

## Services

| Name                 | Version  | Mount Point                 | System Service | Port               | Notes  |
| -------------------- | -------- | --------------------------- | -------------- | ------------------ | -----: |
| Factorio ns          | 59839    | /home/ubuntu/factorio       | yes            | 34197              |  |
| Kerbal Space Program | 1.12.2   | /home/ubuntu/ksp            | yes            | 6702               | Includes `Making History` and `Breaking Ground` expansions. Includes mods, see notice at login. |
| PA:  Titans          | 115958   | /home/ubuntu/pa_titans      | yes            | 20545              | |
| Satisfactory         | Update 5 | /home/ubuntu/.config/Epic   | yes            | 7777, 15000, 15777 | |

## Additional Documentation

- [CHANGELOG.md](./CHANGELOG.md) - Published changes per version of each release
- [ROADMAP.md](./ROADMAP.md) - Ideas to implement
- [RUNBOOK.md](./RUNBOOK.md) - How-to execute actions
