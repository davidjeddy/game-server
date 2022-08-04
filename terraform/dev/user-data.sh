#!/bin/bash

echo "INFO: Starting..."

# -----
# System configuration
# -----

# bash config
set -xe
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# -----
# Application activision toggle
# -----

ENABLE_KSP=true
export ENABLE_KSP
ENABLE_PA_TITANS=true
export ENABLE_PA_TITANS
ENABLE_SATISFACTORY=true
export ENABLE_SATISFACTORY
SYSTEM_TOOLS=true
export SYSTEM_TOOLS

printenv | sort

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

if [[ $SYSTEM_TOOLS ]]
then
    echo "INFO: Install system packages"
    apt-get update -y
    apt-get install -y \
        awscli \
        iotop \
        jq
    apt-get autoremove

    echo "INFO: System package location and versions"
    which aws
    aws --version
    which jq
    jq --version
fi

# -----
# Golang
# -----

if [[ ! $(which go) && $ENABLE_PA_TITANS ]]
then
    echo "INFO: Install Golang language and runtime"
    apt-get update -y
    apt-get install -y golang
    apt-get autoremove

    which go
    go version
fi

# -----
# Mono (.NET runtime library for Linux)
# -----

if [[ ! $(which mono) && $ENABLE_KSP ]]
then
    echo "INFO: Install Mono runtime"
    apt-get update -y
    apt-get install -y \
        dirmngr \
        gnupg \
        apt-transport-https \
        ca-certificates \
        software-properties-common
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
    apt-add-repository 'deb https://download.mono-project.com/repo/ubuntu stable-focal main'
    apt-get install -y mono-complete
    apt-get autoremove

    which mono
    mono --version
fi

# -----
# Steam
# -----

if [[ ! $(which steamcmd) && $ENABLE_SATISFACTORY ]]
then
    echo "INFO: Configure agreement to steamcmd lics"
    echo steam steam/question select "I AGREE" | sudo -u root debconf-set-selections
    echo steam steam/license note '' | sudo -u root debconf-set-selections
    dpkg --add-architecture i386

    echo "INFO: Install the steamcmd system packages" 
    apt-get update -y
    apt-get install -y steamcmd
    apt-get autoremove

    which steamcmd
fi

# -----
# Application install, update, and execution
# -----

# -----
# Satisfactory (.config/Epic)
# -----

if [[ $ENABLE_SATISFACTORY ]]
then
    echo "INFO: Install Satisfactory system packages" 
    apt-get update -y
    apt-get install -y \
        lib32gcc1 \
        libsdl2-2.0-0
    apt-get autoremove

    echo "INFO: Mount Epic EBS volume"
    mkdir -p /home/ubuntu/.config/Epic
    echo "UUID=dc31b9cd-fc42-4ff6-80ee-fb42ea6ce012 /home/ubuntu/.config/Epic ext4 defaults,errors=remount-ro 0 1" >> /etc/fstab
    tail -10 /etc/fstab
    mount -a

    echo "INFO: Resetting user dir ownership"
    chown ubuntu:ubuntu -R /home/ubuntu/.config

    if [[ -d /home/ubuntu/satisfactory ]]
    then
        echo "INFO: Initial install of Satisfactory Dedicated Server"
        sudo -u ubuntu /usr/games/steamcmd \
            +force_install_dir /home/ubuntu/satisfactory \
            +login anonymous \
            +app_update 1690800 \
            -beta public validate \
            +quit
    fi

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

# -----
# KSP
# -----

if [[ $ENABLE_KSP ]]
then
    echo "INFO: Mount KSP EBS volume"
    mkdir -p /home/ubuntu/ksp
    echo "UUID=ede148d6-c668-404f-9836-8ab16cc5b663 /home/ubuntu/ksp ext4 defaults,errors=remount-ro 0 1" >> /etc/fstab
    tail /etc/fstab
    mount -a

    echo "INFO: Resetting user dir ownership"
    chown ubuntu:ubuntu -R /home/ubuntu/ksp

    echo "INFO: Creating symlinks for ksp"
    ln -sfn /home/ubuntu/ksp/etc/dmpserver /etc/dmpserver
    ln -sfn /home/ubuntu/ksp/srv/dmpserver /srv/dmpserver
    ln -sfn /home/ubuntu/ksp/usr/share/dmpserver /usr/share/dmpserver
    ln -sfn /home/ubuntu/ksp/var/lib/dmpserver /var/lib/dmpserver

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
# Planetary Annihilation : Titans
# -----

if [[ $ENABLE_PA_TITANS ]]
then

    echo "INFO: Planetary Annihilation : Titans system packages"
    apt-get update -y
    apt-get install -y \
        libgl1-mesa-glx \
        libsm6 \
        libxext6
    apt-get autoremove

    echo "INFO: Mount Planetary Annihilation : Titans EBS volume"
    mkdir -p /home/ubuntu/pa_titans
    echo "UUID=94006143-dbf5-47e7-b508-470e19728b4c /home/ubuntu/pa_titans ext4 defaults,errors=remount-ro 0 1" >> /etc/fstab
    tail /etc/fstab
    mount -a

    echo "INFO: Resetting user dir ownership"
    chown ubuntu:ubuntu -R /home/ubuntu/pa_titans

    if [[ ! -f /home/ubuntu/pa_titans/PA/stable/server ]]
    then
        echo "INFO: Unpack Planetary Annihilation : Titans archive"
        tar -xf /home/ubuntu/pa_titans/resources/PA_Linux_115872.tar.bz2 -C /home/ubuntu/pa_titans --verbose
    fi

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
            ExecStart=/home/ubuntu/pa_titans/PA/stable/server \
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
            WorkingDirectory=/home/ubuntu/pa_titans/PA/stable/

        [Install]
            WantedBy=multi-user.target" | tee "/etc/systemd/system/pa_titans.service"

        sed -i 's/^ *//g' "/etc/systemd/system/pa_titans.service"

        systemctl enable pa_titans.service --now
    fi

    echo "INFO: Restart pa_titans service"
    systemctl restart pa_titans.service
    systemctl status pa_titans.service
fi

echo "INFO: ...done."
