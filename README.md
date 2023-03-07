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

| Name                              | Mount Point                               | System Service | Port               | Notes  |
| --------------------------------- |  ---------------------------------------- | -------------- | ------------------ | -----: |
| Factorio ns                       | /home/ubuntu/factorio                     | yes            | 34197              | |
| Kerbal Space Program              | /home/ubuntu/ksp                          | yes            | 6702               | Includes `Making History` and `Breaking Ground` expansions. Includes mods, see notice at login. |
| Kerbal Space Program 2            | /home/ubuntu/ksp2                         | yes            | TBD                | |
| PA:  Titans                       | /home/ubuntu/pa_titans                    | yes            | 20545              | |
| Satisfactory                      | /home/ubuntu/satisfactory                 | yes            | 7777, 15000, 15777 | |
| Satisfactory Experimental         | /home/ubuntu/satisfactory_experimental    | yes            | 7778, 15001, 15778 | |

**Note:** Service versions: updated weekly from vendors via a cron job on the running instance.

## Additional Documentation

- [CHANGELOG.md](./CHANGELOG.md) - Published changes per version of each release
- [ROADMAP.md](./ROADMAP.md) - Ideas to implement
- [RUNBOOK.md](./RUNBOOK.md) - How-to execute actions
