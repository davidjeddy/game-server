#!/bin/bash
# tested on Ubuntu 20.10
# version 0.0.2 @ 2021-10-31
# source https://satisfactory.fandom.com/wiki/Dedicated_servers
# source https://github.com/ValveSoftware/steam-for-linux/issues/7036

# bash config
set -e
sleep 5 # couple seconds for the EBS vol. to be attached
cd "/home/ubuntu" || exit


echo "INFO: Starting..."
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1


# -----
# Satisfactory
# -----

echo "INFO: Mount EBS volumne"
lsblk -f
sudo mkdir -p ./.config/Epic || true
sudo umount /home/ubuntu/.config/Epic || true
sudo mount /dev/nvme1n1 ./.config/Epic
sudo chown ubuntu:ubuntu -R ./.config/Epic

if [[ ! $(which steamcmd) ]]
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

    echo "INFO: Reload session to add new tools"
fi

if [[ ! -f "/etc/systemd/system/satisfactory.service" ]]
then
    echo "INFO: Create system service for service"

    echo -e "[Unit]
    Description=Satisfactory dedicated server
    Wants=network-online.target
    After=syslog.target network.target nss-lookup.target network-online.target

[Service]
    Environment="LD_LIBRARY_PATH=./linux64"
    ExecStartPre=/usr/games/steamcmd +login anonymous +force_install_dir "/home/ubuntu/satisfactory" +app_update 1690800 validate +quit
    ExecStart=/home/ubuntu/satisfactory/FactoryServer.sh
    User=ubuntu
    Group=ubuntu
    StandardOutput=journal
    Restart=on-failure
    KillSignal=SIGINT
    WorkingDirectory=/home/ubuntu/satisfactory

[Install]
    WantedBy=multi-user.target" | sudo tee "/etc/systemd/system/satisfactory.service"

    sudo systemctl enable satisfactory.service --now
fi

echo "INFO: Configure journal log limiting"
sudo sed -i 's/#RuntimeMaxUse=*/RuntimeMaxUse=/g' /etc/systemd/journald.conf
sudo sed -i 's/#SystemMaxUse=*/SystemMaxUse=I/g' /etc/systemd/journald.conf

echo "INFO: Restart Satisfactory service"
sudo systemctl restart satisfactory.service
sudo systemctl status satisfactory.service



# -----
# PA
# -----

# -----
# Factorio
# -----

# -----
# KSP
# -----

# -----
# KSP2
# -----

echo "INFO: ...Done."
