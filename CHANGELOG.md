# Changelog

## 0.0.11

- Update logic in EBS tag NAME value, base from pattern the following patter:

```text
Pattern: [game_name]-[version_from_vendor]-[4_character_random_string]-[counter]-[tf_deployment_random_string]
Exp 1: Satisfactory-update5-StDj-0-ux4b
Exp 2: KSP-2.3.7-DjSp-2-ux4b
Exp 3: SupremeCommander-7.5.4-CDJS-0-ux4b
```

## 0.0.10

- Added KMS customer managed key for EBS encryption
- Added KMS CMK for encryption of EBS volumes

## 0.0.9

- Added custom VPC, migrate workload to new VPC
- Remove default VPC and related resources
- Reorganize project structure to support multiple envs (dev,int,sit,tst,stg,prd,etc)

## 0.0.8

- Added `infracost` costing tool

## 0.0.7

- Added `terragrunt` to project
- Added `tfsec` and `terrascan` compliance tools
  - Rule skip/ignore added where needed
- Added metadata_options to ec2_instance

## 0.0.6

- Set Satisfactory to `beta` (Stable) branch in place of `experimental`
