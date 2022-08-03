#!/bin/bash

# tested on Ubuntu 20.04
# source https://satisfactory.fandom.com/wiki/Dedicated_servers
# source https://github.com/ValveSoftware/steam-for-linux/issues/7036
# source https://github.com/godarklight/DarkMultiPlayer
# source https://www.mono-project.com/
# source https://linuxize.com/post/how-to-install-mono-on-ubuntu-20-04/
# source https://gist.github.com/hashashin/490ba1963eb3318a7ea4

echo "INFO: Starting..."

# -----
# Application activision toggle
# -----

ENABLE_KSP=true
ENABLE_SATISFACTORY=true

# -----
# System configuration
# -----

# bash config
set -e
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# -----
# Server wide configurations
# -----

echo "INFO: Configure journal log limiting"
echo "[Journal]
/RuntimeMaxUse=4G
SystemMaxUse=4G" > /etc/systemd/journald.conf

# -----
# Server wide packages install and configuration
# -----

# -----
# Mono (.NET runtime library for Linux)
# -----

if [[ ! $(which mono) && $ENABLE_KSP ]]
then
    echo "INFO: Install Mono runtime"
    apt update -y
    apt install -y \
        dirmngr \
        gnupg \
        apt-transport-https \
        ca-certificates \
        software-properties-common
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
    apt-add-repository 'deb https://download.mono-project.com/repo/ubuntu stable-focal main'
    apt install -y \
        mono-complete
fi
mono --version

# -----
# Steam
# -----

if [[ ! $(which steamcmd) && $ENABLE_SATISFACTORY ]]
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
# Application install, update, and execution
# -----

# -----
# Factorio
# -----

# -----
# KSP
# nvme2n1
# -----

if [[ $ENABLE_KSP ]]
then
    echo "INFO: Mount KSP EBS volume"
    lsblk -f
    umount /home/ubuntu/ksp || true
    rm -rf /home/ubuntu/ksp || true
    mkdir -p /home/ubuntu/ksp || true
    mount -t auto /dev/nvme2n1 /home/ubuntu/ksp

    echo "INFO: Creating symlinks for ksp"
    ln -sfn /home/ubuntu/ksp/etc/dmpserver /etc/dmpserver
    ln -sfn /home/ubuntu/ksp/srv/dmpserver /srv/dmpserver
    ln -sfn /home/ubuntu/ksp/usr/share/dmpserver /usr/share/dmpserver
    ln -sfn /home/ubuntu/ksp/var/lib/dmpserver /var/lib/dmpserver

    echo "INFO: Resetting user dir ownership"
    chown ubuntu:ubuntu -R /home/ubuntu/ksp

    if [[ ! -f "/etc/systemd/system/ksp.service" ]]
    then
        echo "INFO: Create system service for KSP"

        echo -e "\
        [Unit]
            After=syslog.target network.target nss-lookup.target network-online.target
            Description=KSP dedicated server
            Wants=network-online.target

        [Service]
            ExecStart=mono /usr/share/dmpserver/DMPServer.exe
            Group=ubuntu
            KillSignal=SIGINT
            Restart=on-failure
            StandardOutput=journal
            User=ubuntu
            WorkingDirectory=/usr/share/dmpserver

        [Install]
            WantedBy=multi-user.target" | tee "/etc/systemd/system/ksp.service"

        sed -i 's/^ *//g' "/etc/systemd/system/ksp.service"

        systemctl enable ksp.service --now
    fi

    echo "INFO: Restart ksp service"
    systemctl restart ksp.service
    systemctl status ksp.service
fi

# -----
# KSP2
# -----

# -----
# Planetary Annihilation : Titans
# -----

# -----
# Satisfactory (Epic)
# nvme1n1
# -----

if [[ $ENABLE_SATISFACTORY ]]
then
    echo "INFO: Mount Epic EBS volume"
    lsblk -f
    umount /home/ubuntu/.config/Epic || true
    rm -rf /home/ubuntu/.config/Epic || true
    mkdir -p /home/ubuntu/.config/Epic || true
    chown ubuntu:ubuntu -R /home/ubuntu/.config/Epic
    mount -t auto /dev/nvme1n1 /home/ubuntu/.config/Epic

    echo "INFO: Resetting user dir ownership"
    chown ubuntu:ubuntu -R /home/ubuntu/.config

    echo "INFO: Initial install of Satisfactory Dedicated Server"
    sudo -u ubuntu /usr/games/steamcmd \
        +force_install_dir /home/ubuntu/satisfactory \
        +login anonymous \
        +app_update 1690800 \
        -beta public validate \
        +quit

    echo "INFO: Resetting user dir ownership"
    chown ubuntu:ubuntu -R /home/ubuntu

    if [[ ! -f "/etc/systemd/system/satisfactory.service" ]]
    then
        echo "INFO: Create system service for Satisfactory"

        echo -e "\
        [Unit]
            After=syslog.target network.target nss-lookup.target network-online.target
            Description=Satisfactory dedicated server
            Wants=network-online.target

        [Service]
            Environment=\"LD_LIBRARY_PATH=./linux64\"
            ExecStart=/home/ubuntu/satisfactory/FactoryServer.sh
            ExecStartPre=/usr/games/steamcmd +login anonymous +force_install_dir \"/home/ubuntu/satisfactory\" +app_update 1690800 -beta public validate +quit
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

    echo "INFO: Restart Satisfactory service"
    systemctl restart satisfactory.service
    systemctl status satisfactory.service
fi

echo "INFO: ...done."
