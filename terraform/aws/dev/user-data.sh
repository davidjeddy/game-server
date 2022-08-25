#!/bin/bash

# -----
# Application activision toggle
# -----

ENABLE_KSP=true
ENABLE_PA_TITANS=true
ENABLE_PA_UPGRADE=true
ENABLE_SATISFACTORY=true

# -----
# K/V's passed in from ec2_instance.tf
# Key/Values are passed in via instance data.template_file.user_data invocation
# -----

# shellcheck disable=SC2269
PA_TITAN_CRED_ARN="${PA_TITAN_CRED_ARN}"\

# shellcheck disable=SC2269
REGION="${REGION}"

# -----
# File system assignments
# -----

KSP_FS_UUID="71ce6087-ec2e-4df1-857b-ab1c7888d75b"
PA_TITANS_FS_UUID="4df99be4-b9b5-4394-ab47-ed92ee1c9252"
SATISFACTORY_FS_UUID="a0a3e05f-3e49-49a8-94fa-b9c220720d07"

# -----
# System configuration
# -----

set -e
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# -----
# Server wide configurations
# -----

echo "INFO: Starting..."

echo "INFO: Configure journal log limiting"
echo "[Journal]
/RuntimeMaxUse=4G
SystemMaxUse=4G" > /etc/systemd/journald.conf

# -----
# Server wide packages install and configuration
# -----

echo "INFO: Install system packages"
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
apt-add-repository 'deb https://download.mono-project.com/repo/ubuntu stable-focal main'

apt update -y
apt install -y \
    apt-transport-https \
    awscli \
    ca-certificates \
    dirmngr \
    gnupg \
    iotop \
    jq \
    software-properties-common
apt autoremove

echo "INFO: System package location and versions"
aws --version
jq --version
which aws
which jq

# -----
# Service system package requirements
#-----

echo "INFO: Install Golang language and runtime"
echo steam steam/question select "I AGREE" | sudo -u root debconf-set-selections
echo steam steam/license note "" | sudo -u root debconf-set-selections
dpkg --add-architecture i386

apt update -y
apt install -y \
    golang \
    mono-complete \
    steamcmd
apt autoremove

echo "INFO: Service system package location and versions"
go version
mono --version
which go
which mono

# -----
# Application install, update, configuration, and execution
# -----

# -----
# KSP (~/ksp)
# -----

if [[ $ENABLE_KSP == true ]]
then
    echo "INFO: Mount Kerbal Space Program EBS volume"
    mkdir -p /home/ubuntu/ksp
    echo "UUID=$KSP_FS_UUID /home/ubuntu/ksp ext4 defaults,errors=remount-ro 0 1" >> /etc/fstab
    tail /etc/fstab
    mount -a

    echo "INFO: Resetting Kerbal Space Program dir ownership"
    chown ubuntu:ubuntu -R /home/ubuntu/ksp

    if [[ ! -f "/etc/systemd/system/ksp.service" ]]
    then
        echo "INFO: Creating symlinks for ksp"
        ln -sfn /home/ubuntu/ksp/etc/dmpserver /etc/dmpserver
        ln -sfn /home/ubuntu/ksp/srv/dmpserver /srv/dmpserver
        ln -sfn /home/ubuntu/ksp/usr/share/dmpserver /usr/share/dmpserver
        ln -sfn /home/ubuntu/ksp/var/lib/dmpserver /var/lib/dmpserver

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
        systemctl restart ksp.service
    fi

    echo "INFO: Kerbal Space Program service status"
    systemctl status ksp.service
fi

# -----
# Planetary Annihilation : Titans (~/ps_titans)
# -----

if [[ $ENABLE_PA_TITANS == true ]]
then
    echo "INFO: Mount Planetary Annihilation : Titans EBS volume"
    mkdir -p /home/ubuntu/pa_titans
    echo "UUID=$PA_TITANS_FS_UUID /home/ubuntu/pa_titans ext4 defaults,errors=remount-ro 0 1" >> /etc/fstab
    tail /etc/fstab
    mount -a

    echo "INFO: Resetting Planetary Annihilation : Titans dir ownership"
    chown ubuntu:ubuntu -R /home/ubuntu/pa_titans

    echo "INFO: Planetary Annihilation : Titans system packages"
    apt update -y
    apt install -y \
        libgl1-mesa-glx \
        libsdl2-dev \
        libsm6 \
        libxext6
    apt autoremove

    if [[ ! -f /home/ubuntu/pa_titans/PA/stable/server ]]
    then
        echo "INFO: Unpack Planetary Annihilation : Titans archive"
        mkdir -p /home/ubuntu/pa_titans/stable
        tar -xf /home/ubuntu/pa_titans/resources/PA_Linux_115872.tar.bz2 -C /home/ubuntu/pa_titans/stable --verbose
    fi

    if [[ $ENABLE_PA_UPGRADE == true ]]
    then
        echo "INFO: Patching Planetary Annihilation : Titans from stable branch"
        mkdir -p /home/ubuntu/.cache
        XDG_CACHE_HOME=/home/ubuntu/.cache
        export XDG_CACHE_HOME

        # Key/Values are passed in via instance data.template_file.user_data invocation
        # shellcheck disable=SC2086
        go run /home/ubuntu/pa_titans/resources/papatcher.go \
            --dir /home/ubuntu/pa_titans/PA/ \
            --stream stable \
            --update-only \
            --username "$(aws secretsmanager get-secret-value --region $REGION --secret-id $PA_TITAN_CRED_ARN --query SecretString --output text | jq -r .username)" \
            --password "$(aws secretsmanager get-secret-value --region $REGION --secret-id $PA_TITAN_CRED_ARN --query SecretString --output text | jq -r .password)"
    fi

    echo "INFO: Version of Planetary Annihilationvers : Titans is $(cat /home/ubuntu/pa_titans/PA/version.txt)"

    if [[ ! -f "/etc/systemd/system/pa_titans.service" ]]
    then
        echo "INFO: Create system service for Planetary Annihilation : Titans"

        mkdir -p "/home/ubuntu/.local/Uber Entertainment/PA Server/log/"
        mkdir -p "/home/ubuntu/pa_titans/download"
        mkdir -p "/home/ubuntu/pa_titans/network"
        mkdir -p "/home/ubuntu/pa_titans/output"

        echo -e "\
        [Unit]
            After=syslog.target network.target nss-lookup.target network-online.target
            Description=Planetary Annihilation : Titans dedicated server
            Wants=network-online.target

        [Service]
            ExecStart=/home/ubuntu/pa_titans/PA/stable/server \
                --allow-lan \
                --game-mode \"PAExpansion1:config\" \
                --gameover-timeout 360 \
                --headless \
                --max-players 8 \
                --max-spectators 2 \
                --mt-enabled \
                --output-dir /home/ubuntu/pa_titans/output \
                --port 20545 \
                --replay-filename \"UTCTIMESTAMP\" \
                --replay-timeout 180 \
                --server-name \"LanOrDie_PA_Titans\"

            Group=ubuntu
            KillSignal=SIGINT
            NoNewPrivileges=yes
            PrivateDevices=yes
            PrivateTmp=yes
            ProtectControlGroups=yes
            ProtectKernelModules=yes
            ProtectKernelTunables=yes
            Restart=on-failure
            StandardOutput=journal
            User=ubuntu
            WorkingDirectory=/home/ubuntu/pa_titans/PA/stable/

        [Install]
            WantedBy=multi-user.target" | tee "/etc/systemd/system/pa_titans.service"

        sed -i 's/^ *//g' "/etc/systemd/system/pa_titans.service"

        systemctl enable pa_titans.service --now
        systemctl restart pa_titans.service
    fi

    echo "INFO: Planetary Annihilation : Titans service status"
    systemctl status pa_titans.service
fi

# -----
# Satisfactory (~/.config/Epic/satisfactory)
# -----

if [[ $ENABLE_SATISFACTORY == true ]]
then
    echo "INFO: Mount Epic EBS volume"
    mkdir -p /home/ubuntu/.config/Epic
    echo "UUID=$SATISFACTORY_FS_UUID /home/ubuntu/.config/Epic ext4 defaults,errors=remount-ro 0 1" >> /etc/fstab
    tail -10 /etc/fstab
    mount -a

    echo "INFO: Resetting Satisfactory dir ownership"
    chown ubuntu:ubuntu -R /home/ubuntu/.config/Epic

    echo "INFO: Install Satisfactory system packages" 
    apt update -y
    apt install -y \
        lib32gcc1 \
        libsdl2-2.0-0
    apt autoremove

    if [[ ! -d /home/ubuntu/.config/Epic/satisfactory ]]
    then
        echo "INFO: Install of Satisfactory Dedicated Server via steamcmd"
        mkdir -p /home/ubuntu/.config/Epic/satisfactory
        sudo -u ubuntu /usr/games/steamcmd \
            +force_install_dir /home/ubuntu/.config/Epic/satisfactory \
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
            ExecStart=/home/ubuntu/.config/Epic/satisfactory/FactoryServer.sh
            ExecStartPre=/usr/games/steamcmd +login anonymous +force_install_dir \"/home/ubuntu/.config/Epic/satisfactory\" +app_update 1690800 -beta public validate +quit
            Group=ubuntu
            KillSignal=SIGINT
            Restart=on-failure
            StandardOutput=journal
            User=ubuntu
            WorkingDirectory=/home/ubuntu/.config/Epic/satisfactory

        [Install]
            WantedBy=multi-user.target" | tee "/etc/systemd/system/satisfactory.service"

        sed -i 's/^ *//g' "/etc/systemd/system/satisfactory.service"

        systemctl enable satisfactory.service --now
        systemctl restart satisfactory.service
    fi

    echo "INFO: Satisfactory service status"
    systemctl status satisfactory.service
fi

echo "INFO: ...done."
