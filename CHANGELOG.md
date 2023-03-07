# Changelog

## 0.0.22

- MOVED title install / system service creation out of user-data.sh, now resides in installer.sh which is stored in the S3 bucket `installers`.
- ADDED archive for Factorio, KSP, and PA:Titans to `installer` S3 bucket. Titles now install from archives in S3 if missing on EC2 instance

## 0.0.20

- ADD Satisfactory Experimental service
- ADD Instance user-data.sh migrated back to Terraform, no counter-productive to rebuild the AMI for the smallest changes to instance start-up behavior.

## 0.0.19

- EC2 SSH pem key lifecycle now tied to instance lifecycle
- ADD Packer to build base AMI
- ADD DLM to manager snapshot lifecycle

## 0.0.18

- Added Factorio service

## 0.0.17

- Replace static ARN with dynamic sources in [iam.tf](terraform/aws/dev/iam.tf)
- Build PA Titans credentials secret ARN from vars, not static string, in user-data.sh
- Migrate resources from davidjeddy account to eddy enterprises / lanordie account

## 0.0.16

- Move Satisfactory runtime resources to ./config/ EBS volume

## 0.0.15

- Added Data Lifecycle Management resources for EBS volumes

## 0.0.14

- Fixed EBS volume mounting. Now uses fstab to ensure mounts are at the same location every time

## 0.0.13

- Added `Planetary Annihilation : Titans` service
  - Added Secrets Manager and AWS CLI to game-server ec2 instance IAM role

## 0.0.12

- Added `Kerbal Space Program` DarkMultiPlayer (KSP DMP) server
  - KSM, EBS, user-data.sh, system service added

## 0.0.11

- Update logic in EBS tag NAME value, base from pattern the following patter:

```text
Pattern: [game_name]-[version_from_vendor]-[4_character_random_string]-[counter]-[tf_deployment_random_string]
Exp 1: satisfactory-update5-coffeestainstudios-StDj-0-ux4b
Exp 2: ksp-1.x-squad-DjSp-2-ux4b
Exp 3: planetaryannihilation-titans-planetaryannihilationinc-7.5.4-CDJS-0-ux4b
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

## 0.0.5

- Added `Satisfactory` service
