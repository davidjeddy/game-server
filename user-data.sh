#!/bin/bash
# tested on Ubuntu 20.10
# version 0.0.6 @ 2022-01-30
# source https://satisfactory.fandom.com/wiki/Dedicated_servers
# source https://github.com/ValveSoftware/steam-for-linux/issues/7036

# bash config
set -e
echo "INFO: Starting..."
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# -----
# Steam
# -----

echo "INFO: Install steamcmd"
if [[ ! $(which steamcmd) ]]
then
    echo "INFO: Configure agreement to steamcmd lics"
    echo steam steam/question select "I AGREE" | debconf-set-selections
    echo steam steam/license note "" | debconf-set-selections

    echo "INFO: Install system packages" 
    add-apt-repository multiverse
    dpkg --add-architecture i386
    apt update -y
    apt install -y \
        lib32gcc1 \
        libsdl2-2.0-0 \
        steamcmd
fi

# -----
# Satisfactory
# -----

echo "INFO: Mount Epic EBS volume"
lsblk -f
umount /home/ubuntu/.config/Epic || true
rm -rf /home/ubuntu/.config/Epic || true
mkdir -p /home/ubuntu/.config/Epic || true
chown ubuntu:ubuntu -R /home/ubuntu/.config/Epic
mount /dev/nvme1n1 /home/ubuntu/.config/Epic

echo "INFO: Initial install of Satisfactory Dedicated Server"
/usr/games/steamcmd/steamcmd.sh \
    +app_update 1690800 validate \
    +force_install_dir /home/ubuntu/satisfactory \
    +login anonymous \
    -beta public \
    +quit

echo "INFO: Resetting user dir ownership"
chown ubuntu:ubuntu -R /home/ubuntu

if [[ ! -f "/etc/systemd/system/satisfactory.service" ]]
then
    echo "INFO: Create system service for service"

    echo -e "\
    [Unit]
        After=syslog.target network.target nss-lookup.target network-online.target
        Description=Satisfactory dedicated server
        Wants=network-online.target

    [Service]
        Environment=\"LD_LIBRARY_PATH=./linux64\"
        ExecStart=/home/ubuntu/satisfactory/FactoryServer.sh
        ExecStartPre=/usr/games/steamcmd/steamcmd.sh +login anonymous +force_install_dir \"/home/ubuntu/satisfactory\" +app_update 1690800 -beta public validate +quit
        Group=ubuntu
        KillSignal=SIGINT
        Restart=on-failure
        StandardOutput=journal
        User=ubuntu
        WorkingDirectory=/home/ubuntu/satisfactory

    [Install]
        WantedBy=multi-user.target" | tee "/etc/systemd/system/satisfactory.service"

    sed -i 's/^ *//g' "/etc/systemd/system/satisfactory.service"

    systemctl enable satisfactory.service --now
fi

echo "INFO: Configure journal log limiting"
sed -i 's/#RuntimeMaxUse=*/RuntimeMaxUse=4G/g' /etc/systemd/journald.conf
sed -i 's/#SystemMaxUse=*/SystemMaxUse=4G/g' /etc/systemd/journald.conf

echo "INFO: Restart Satisfactory service"
systemctl restart satisfactory.service
systemctl status satisfactory.service

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
