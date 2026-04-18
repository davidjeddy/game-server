[!WARNING]
**⚠️ This project has been archived and is no longer maintained. ⚠️**

Github has shown it does not respect its users. Other have said it better than I can.

- https://www.theregister.com/2022/06/30/software_freedom_conservancy_quits_github/
- https://www.andrlik.org/dispatches/migrating-from-github-motivation/
- https://techresolve.blog/2025/12/27/looking-to-migrate-company-off-github-whats-the/
- https://lord.io/leaving-github/
- https://dev.to/alanwest/how-to-actually-migrate-from-github-to-codeberg-without-losing-your-mind-33bf>
> Development has moved to Codeberg:
> **➡️ https://codeberg.org/DavidJEddy/game-server**
>
> Please update your remotes:
> ```bash
> git remote set-url origin https://codeberg.org/DavidJEddy/game-server
> ```

---
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

| Name                 | Version  | Device  | Mount Point                 | System Service | Port               | Notes  |
| -------------------- | -------- | ------- | --------------------------- | -------------- | ------------------ | -----: |
| Kerbal Space Program | 1.12.2   | nvme2n1 | /home/ubuntu/ksp            | yes            | 6702               | Includes `Making History` and `Breaking Ground` expansions. Includes mods, see notice at login. |
| PA : Titans          | 115958   | nvme3n1 | /home/ubuntu/pa_titans      | yes            | 20545              | |
| Satisfactory         | Update 5 | nvme1n1 | /home/ubuntu/.config/Epic   | yes            | 7777, 15000, 15777 | |

## Additional Documentation

- [CHANGELOG.md](./CHANGELOG.md) - Published changes per version of each release
- [ROADMAP.md](./ROADMAP.md) - Ideas to implement
- [RUNBOOK.md](./RUNBOOK.md) - How-to execute actions

## Bugs

- KSP : DMP vessel ownership needs reset
- PA : Titans is binding to locahost or 127.0.0.1, not the public interface.