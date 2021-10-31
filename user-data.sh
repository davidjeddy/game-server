#!/bin/bash
# tested on Ubuntu 20.10
# version 0.0.2 @ 2021-10-31
# source https://satisfactory.fandom.com/wiki/Dedicated_servers
# source https://github.com/ValveSoftware/steam-for-linux/issues/7036

# bash config
set -e

echo "INFO: Starting..."
cd "/home/ubuntu" || exit

# only do this if running in non-interactive mode
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "INFO: Mount EBS volumne"
mkdir -p ./Satisfactory
sudo mount /dev/nvme1n1 ./Satisfactory
sudo chown ubuntu:ubuntu -R ./Satisfactory/

if [[ ! -f "/home/ubuntu/Satisfactory/FactoryServer.sh" ]]
then
    echo "INFO: Configure agreement to steamcmd lics..."
    echo steam steam/question select "I AGREE" | sudo debconf-set-selections
    echo steam steam/license note "" | sudo debconf-set-selections

    echo "INFO: Install system packages" 
    sudo add-apt-repository multiverse
    sudo dpkg --add-architecture i386
    sudo apt update -y
    sudo apt install -y \
        lib32gcc1 \
        libsdl2-2.0-0 \
        steamcmd

    echo "INFO: Install server package from Steam"
    steamcmd +login anonymous +force_install_dir "/home/ubuntu/Satisfactory" +app_update 1690800 -validate +quit
fi

# -----

if [[ ! -f "/etc/systemd/system/satisfactory.service" ]]
then
    echo "INFO: Create system service for service"

    echo -e "\
[Unit]
    Description=Satisfactory dedicated server
    Wants=network-online.target
    After=syslog.target network.target nss-lookup.target network-online.target

[Service]
    Environment=\"LD_LIBRARY_PATH=./linux64\"
    ExecStart=\"/home/ubuntu/Satisfactory/FactoryServer.sh\"
    ExecStartPre=/usr/games/steamcmd +login anonymous +force_install_dir \"/home/ubuntu/Satisfactory\" +app_update 1690800 validate +quit
    Group=ubuntu
    KillSignal=SIGINT
    Restart=on-failure
    StandardOutput=journal
    TimeoutSec=30
    User=ubuntu
    WorkingDirectory=/home/ubuntu/Satisfactory

[Install]
    WantedBy=multi-user.target" | sudo tee "/etc/systemd/system/satisfactory.service"

    sudo systemctl enable satisfactory.service --now
    sudo systemctl restart satisfactory.service

    echo "INFO: To re/start the service manually run: sudo systemctl restart satisfactory.service"
fi

if [[ ! -f /etc/logrotate.d/satisfactory.conf ]]
then
    echo "INFO: Configuring logrotate..."

    echo "/home/ubuntu/Satisfactory/server.log* {
    weekly
    rotate 7
    size 10M
    compress
    delaycompress
}" | sudo tee /etc/logrotate.d/satisfactory.conf
    sudo logrotate -d /etc/logrotate.d/satisfactory.conf

    echo "INFO: logrotate configuration completed..."
fi

echo "INFO: ...Done."
