# How To

## Provisioning

### Deploy Resources

Edit `terraform.tfvars` as needed. Then ...

```sh
terragrunt init
terragrunt plan
terragrunt apply
```

### Format and Mount Data Drive

```sh
sudo mkfs.ext4 /dev/nvme1n1
```

### Mount Data Disk

```sh
sudo mount -t auto /dev/nvme1n1 /home/ubuntu/.config/Epic
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

source: https://satisfactory.fandom.com/wiki/Dedicated_servers

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
