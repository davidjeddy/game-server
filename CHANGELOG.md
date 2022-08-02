# Changelog

## 0.0.10

- Added KMS customer managed key for EBS encryption

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
