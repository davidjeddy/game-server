# How To

## Provisioning

### Deploy Resources

```sh
git clone ...
cd terraform/aws/dev
cp terraform.tfvars.dist terraform.tfvars
# populate values in terraform.tfvars
```

- Log into AWS account using the root user
- Create `Admin` user xziP51QzSJ&2g*q*G4jhPe8GA@mTV6DX%A43d5^fMn@xsd5@r#uBW0D%rk25O%lN
- Assign `AdministratorAccess` role to user
- [Create API Key pair](https://us-east-1.console.aws.amazon.com/ec2/v2/home?region=us-east-1#KeyPairs:)
  - Configuration: ED25519, .pem
- Create EC2 key pair, save to localhost ~/.ssh/*

```sh
terragrunt apply --target  aws_secretsmanager_secret.pa_titans
```

- Populate the value for the PA account login credentials in Secrets Manager, it will be named something similar to `gs/pa_titans-*-0-*`.
- Edit lanordie/terraform/aws/dev/user-data.sh `PA_TITAN_CRED_ARN` value with the value from Terragrunt output `aws_secretsmanager_secret_pa_titans`.

Now, create all the other resources

```sh
terragrunt init
terragrunt plan
terragrunt apply
```

### Format and Mount Data Drive

```sh
lsblk -f
sudo mkfs.ext4 /dev/nvme1n1
sudo mkfs.ext4 /dev/nvme2n1
sudo mkfs.ext4 /dev/nvme3n1
...
sudo mkfs.ext4 /dev/nvme[[N]]n1
```

### Attach and Mount Disk

On a development host

```sh
aws ec2 attach-volume --device /dev/sd[a-z] --instance-id [instance_id] --volume-id [volume_id] --profile [aws_profile] --region [target_region]
#aws ec2 detach-volume --device /dev/sd[a-z] --instance-id [instance_id] --volume-id [volume_id] --profile [aws_profile] --region [target_region]
```

```sh
mkdir -p /home/ubuntu/pa_titans
sudo mount -t auto /dev/nvme3n1 /home/ubuntu/pa_titans
sudo chown ubuntu:ubuntu -R ~/
```

## IAC support tooling

### infracost update base resource

```sh
infracost breakdown \
    --path . \
    --format json \
    --project-name lanordie/[[ENV]] \
    --out-file infracost-base.json
```

Then Git commit and push

```sh
git add */infracost-base.json
git commit -m "Updated infracost-base.json"
git push origin
```

## Satisfactory

### Update Satisfactory

```sh
sudo systemctl stop satisfactory.service
```

### Switch to Experimental

[Satisfactory Dedicated Server](https://satisfactory.fandom.com/wiki/Dedicated_servers)

- Stop any running process

```sh
systemctl stop satisfactory.service
```

- Backup data
- [edit the system service](/etc/systemd/system/satisfactory.service)

```sh
...+app_update 1690800 -beta public validate +quit
```

to

```sh
... +app_update 1690800 -beta experimental validate +quit
```

run the following command

```sh
/usr/games/steamcmd +login anonymous +force_install_dir \"/home/ubuntu/satisfactory\" +app_update 1690800 -beta public validate +quit
```

- start the system service

```sh
systemctl start satisfactory.service
```

## Add new service

- Create random string resource
- Create KMS CMK resource
- Create Security Group rule
- Create EBS block store
- Update user-data.sh
  - mount drive
  - install application
  - create/start system service
- Update README.md `Services` list

## Backup user file system

```sh
cd [[project_root]]

# KSP
scp -i ~/.ssh/$KEY_NAME -C -r -p ubuntu@[[REMOTE_IP]:/home/ubuntu ./backup/home/ubuntu/ksp

# Satisfactory
scp -i ~/.ssh/$KEY_NAME -C -r -p ubuntu@$REMOTE_IP:/home/ubuntu/.config/Epic/FactoryGame/Saved ./backup/home/ubuntu/.config/Epic/FactoryGame/Saved

# PA: Titans
scp -i ~/.ssh/$KEY_NAME -C -r -p ubuntu@$REMOTE_IP:/home/ubuntu/pa_titans ./backup/home/ubuntu/pa_titans
```

## Restore user file system

```sh
cd [[project_root]]
scp -i ~/.ssh/$KEY_NAME -C -r -p ./backup/home/ubuntu/ksp ubuntu@$REMOTE_IP:~/ksp 
scp -i ~/.ssh/$KEY_NAME -C -r -p ./backup/home/ubuntu/pa_titans ubuntu@$REMOTE_IP:~/pa_titans
scp -i ~/.ssh/$KEY_NAME -C -r -p ./backup/home/ubuntu/.config/Epic/FactoryGame/Saved ubuntu@$REMOTE_IP:~/.config/Epic/FactoryGame/Saved
```
