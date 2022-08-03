#!/bin/bash

echo "INFO: Starting..."

# -----
# Application activision toggle
# -----

ENABLE_KSP=true
ENABLE_PA_TITANS=true
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

echo "INFO: Install system packages"
apt update -y
apt install -y \
    awscli \
    jq \
    libsm6 \
    libxext6

echo "INFO: System package location and versions"
which aws
aws --version
which jq
jq --version

# -----
# Golang
# -----

if [[ ! $(which go) && $ENABLE_PA_TITANS ]]
then
    echo "INFO: Install Golang language and runtime"
    apt update -y
    apt install -y golang

    which go
    go version
fi

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


    which mono
    mono --version
fi

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

    which steamcmd
fi

# -----
# Application install, update, and execution
# -----

# -----
# Factorio
# -----

# -----
# KSP
# nvme1n1
# -----

if [[ $ENABLE_KSP ]]
then
    echo "INFO: Mount KSP EBS volume"
    lsblk -f
    umount /home/ubuntu/ksp || true
    rm -rf /home/ubuntu/ksp || true
    mkdir -p /home/ubuntu/ksp || true
    mount -t auto /dev/nvme1n1 /home/ubuntu/ksp

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
# nvme3n1
# -----

if [[ $ENABLE_PA_TITANS ]]
then
    echo "INFO: Mount Planetary Annihilation : Titans EBS volume"
    lsblk -f
    umount /home/ubuntu/pa_titans || true
    rm -rf /home/ubuntu/pa_titans || true
    mkdir -p /home/ubuntu/pa_titans/output || true
    mount -t auto /dev/nvme3n1 /home/ubuntu/pa_titans

    if [[ ! -f /home/ubuntu/pa_titans/PA/server ]]
    then
        echo "INFO: Unpack Planetary Annihilation : Titans archive"
        tar -xf /home/ubuntu/pa_titans/resources/PA_Linux_115872.tar.bz2 -C /home/ubuntu/pa_titans --verbose
    fi

    echo "INFO: Resetting user dir ownership"
    chown ubuntu:ubuntu -R /home/ubuntu/pa_titans

    echo "INFO: Patching Planetary Annihilation : Titans from stable branch"
    go run /home/ubuntu/pa_titans/resources/papatcher.go \
        --dir /home/ubuntu/pa_titans/PA/ \
        --stream stable \
        --update-only \
        --username "$(aws secretsmanager get-secret-value --region us-east-1 --secret-id arn:aws:secretsmanager:us-east-1:530589290119:secret:gs/pa_titans-uops-0-ux4b-WYzVAB --query SecretString --output text | jq -r .username)" \
        --password "$(aws secretsmanager get-secret-value --region us-east-1 --secret-id arn:aws:secretsmanager:us-east-1:530589290119:secret:gs/pa_titans-uops-0-ux4b-WYzVAB --query SecretString --output text | jq -r .password)"

    echo "INFO: Version of Planetary Annihilationvers : Titans is $(cat /home/ubuntu/pa_titans/PA/version.txt)"

    if [[ ! -f "/etc/systemd/system/pa_titans.service" ]]
    then
        echo "INFO: Create system service for Planetary Annihilation : Titans"

        echo -e "\
        [Unit]
            After=syslog.target network.target nss-lookup.target network-online.target
            Description=Planetary Annihilation : Titans dedicated server
            Wants=network-online.target

        [Service]
            ExecStart=/home/ubuntu/pa_titans/PA/server \
                --port 20545 \
                --headless \
                --mt-enabled \
                --max-players 8 \
                --max-spectators 2 \
                --spectators 2 \
                --empty-timeout 5 \
                --enable-crash-reporting \
                --replay-filename \"UTCTIMESTAMP\" \
                --replay-timeout 180 \
                --gameover-timeout 360 \
                --server-name \"LanOrDie_PA_Titans\" \
                --game-mode \"PAExpansion1:config\" \
                --output-dir /home/ubuntu/pa_titans/output
            Group=ubuntu
            KillSignal=SIGINT
            Restart=on-failure
            StandardOutput=journal
            User=ubuntu
            WorkingDirectory=/home/ubuntu/pa_titans/PA/

        [Install]
            WantedBy=multi-user.target" | tee "/etc/systemd/system/pa_titans.service"

        sed -i 's/^ *//g' "/etc/systemd/system/pa_titans.service"

        systemctl enable pa_titans.service --now
    fi

    echo "INFO: Restart pa_titans service"
    systemctl restart pa_titans.service
    systemctl status pa_titans.service
fi

# -----
# Satisfactory (Epic)
# nvme2n1
# -----

if [[ $ENABLE_SATISFACTORY ]]
then
    echo "INFO: Mount Epic EBS volume"
    lsblk -f
    umount /home/ubuntu/.config/Epic || true
    rm -rf /home/ubuntu/.config/Epic || true
    mkdir -p /home/ubuntu/.config/Epic || true
    mount -t auto /dev/nvme2n1 /home/ubuntu/.config/Epic

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
