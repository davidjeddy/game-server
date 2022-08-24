# How To

## Provisioning

### Deploy Resources

```sh
git clone ...
cd terraform/aws/dev
cp terraform.tfvars.dist terraform.tfvars
```

- Log into AWS account using the root user
- Create `Admin` user xziP51QzSJ&2g*q*G4jhPe8GA@mTV6DX%A43d5^fMn@xsd5@r#uBW0D%rk25O%lN
- Assign `AdministratorAccess` role to user
- Create API Key pair

```sh
# populate values in terraform.tfvars
terragrunt init
terragrunt plan
terragrunt apply
```

### Format and Mount Data Drive

```sh
lsblk -f
sudo mkfs.ext4 /dev/nvme3n1
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

## Backup game save / recording / configurations files

```sh
# Factorio

# KSP
scp -i ~/.ssh/[[KEY_NAME]] -C -r -p ubuntu@[[REMOTE_IP]:/home/ubuntu/ksp ./backup/home/ubuntu/ksp

# Satisfactory
scp -i ~/.ssh/[[KEY_NAME]] -C -r -p ubuntu@[[REMOTE_IP]]:/home/ubuntu/.config/Epic/FactoryGame/Saved ./backup/home/ubuntu/.config/Epic/FactoryGame/Saved

# PA: Titans
scp -i ~/.ssh/[[KEY_NAME]] -C -r -p ubuntu@[[REMOTE_IP]]:/home/ubuntu/pa_titans/resources ./backup/home/ubuntu/pa_titans/resources
```
