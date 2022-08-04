#!/bin/bash

# -----
# Application activision toggle
# -----

ENABLE_KSP=true
ENABLE_PA_TITANS=true
ENABLE_SATISFACTORY=true
GS_ROOT=/home/ubuntu

# -----
# Do not edit below this line
# -----

# -----
# System configuration
# -----

echo "INFO: Starting..."

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
# Application install, update, and execution
# -----

# -----
# KSP (~/ksp)
# -----

if [[ $ENABLE_KSP == true ]]
then
    echo "INFO: Mount KSP EBS volume"
    mkdir -p $GS_ROOT/ksp
    echo "UUID=ede148d6-c668-404f-9836-8ab16cc5b663 $GS_ROOT/ksp ext4 defaults,errors=remount-ro 0 1" >> /etc/fstab
    tail /etc/fstab
    mount -a

    echo "INFO: Resetting user dir ownership"
    chown ubuntu:ubuntu -R $GS_ROOT/ksp

    if [[ ! -f "/etc/systemd/system/ksp.service" ]]
    then
        echo "INFO: Creating symlinks for ksp"
        ln -sfn $GS_ROOT/ksp/etc/dmpserver /etc/dmpserver
        ln -sfn $GS_ROOT/ksp/srv/dmpserver /srv/dmpserver
        ln -sfn $GS_ROOT/ksp/usr/share/dmpserver /usr/share/dmpserver
        ln -sfn $GS_ROOT/ksp/var/lib/dmpserver /var/lib/dmpserver

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

    echo "INFO: Restart ksp service"
    systemctl status ksp.service
fi

# -----
# Planetary Annihilation : Titans (~/ps_titans)
# -----

if [[ $ENABLE_PA_TITANS == true ]]
then
    echo "INFO: Mount Planetary Annihilation : Titans EBS volume"
    mkdir -p $GS_ROOT/pa_titans
    echo "UUID=94006143-dbf5-47e7-b508-470e19728b4c $GS_ROOT/pa_titans ext4 defaults,errors=remount-ro 0 1" >> /etc/fstab
    tail /etc/fstab
    mount -a

    echo "INFO: Resetting user dir ownership"
    chown ubuntu:ubuntu -R $GS_ROOT/pa_titans

    echo "INFO: Planetary Annihilation : Titans system packages"
    apt update -y
    apt install -y \
        libgl1-mesa-glx \
        libsm6 \
        libxext6
    apt autoremove

    if [[ ! -f $GS_ROOT/pa_titans/PA/stable/server ]]
    then
        echo "INFO: Unpack Planetary Annihilation : Titans archive"
        tar -xf $GS_ROOT/pa_titans/resources/PA_Linux_115872.tar.bz2 -C $GS_ROOT/pa_titans --verbose
    fi

    echo "INFO: Patching Planetary Annihilation : Titans from stable branch"
    mkdir -p $GS_ROOT/.cache
    XDG_CACHE_HOME=$GS_ROOT/.cache
    export XDG_CACHE_HOME

    go run $GS_ROOT/pa_titans/resources/papatcher.go \
        --dir $GS_ROOT/pa_titans/PA/ \
        --stream stable \
        --update-only \
        --username "$(aws secretsmanager get-secret-value --region us-east-1 --secret-id arn:aws:secretsmanager:us-east-1:530589290119:secret:gs/pa_titans-uops-0-ux4b-WYzVAB --query SecretString --output text | jq -r .username)" \
        --password "$(aws secretsmanager get-secret-value --region us-east-1 --secret-id arn:aws:secretsmanager:us-east-1:530589290119:secret:gs/pa_titans-uops-0-ux4b-WYzVAB --query SecretString --output text | jq -r .password)"

    echo "INFO: Version of Planetary Annihilationvers : Titans is $(cat $GS_ROOT/pa_titans/PA/version.txt)"

    if [[ ! -f "/etc/systemd/system/pa_titans.service" ]]
    then
        echo "INFO: Create system service for Planetary Annihilation : Titans"
        echo -e "\
        [Unit]
            After=syslog.target network.target nss-lookup.target network-online.target
            Description=Planetary Annihilation : Titans dedicated server
            Wants=network-online.target

        [Service]
            ExecStart=$GS_ROOT/pa_titans/PA/stable/server \
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
                --output-dir $GS_ROOT/pa_titans/output
            Group=ubuntu
            KillSignal=SIGINT
            Restart=on-failure
            StandardOutput=journal
            User=ubuntu
            WorkingDirectory=$GS_ROOT/pa_titans/PA/stable/

        [Install]
            WantedBy=multi-user.target" | tee "/etc/systemd/system/pa_titans.service"

        sed -i 's/^ *//g' "/etc/systemd/system/pa_titans.service"

        systemctl enable pa_titans.service --now
        systemctl restart pa_titans.service
    fi

    echo "INFO: Restart pa_titans service"
    systemctl status pa_titans.service
fi

# -----
# Satisfactory (~/.config/Epic)
# -----

if [[ $ENABLE_SATISFACTORY == true ]]
then
    echo "INFO: Mount Epic EBS volume"
    mkdir -p $GS_ROOT/.config/Epic
    echo "UUID=dc31b9cd-fc42-4ff6-80ee-fb42ea6ce012 $GS_ROOT/.config/Epic ext4 defaults,errors=remount-ro 0 1" >> /etc/fstab
    tail -10 /etc/fstab
    mount -a

    echo "INFO: Resetting user dir ownership"
    chown ubuntu:ubuntu -R $GS_ROOT/.config

    echo "INFO: Install Satisfactory system packages" 
    apt update -y
    apt install -y \
        lib32gcc1 \
        libsdl2-2.0-0
    apt autoremove

    if [[ ! -d $GS_ROOT/satisfactory ]]
    then
        echo "INFO: Install of Satisfactory Dedicated Server via steamcmd"
        sudo -u ubuntu /usr/games/steamcmd \
            +force_install_dir $GS_ROOT/satisfactory \
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
            ExecStart=$GS_ROOT/satisfactory/FactoryServer.sh
            ExecStartPre=/usr/games/steamcmd +login anonymous +force_install_dir \"$GS_ROOT/satisfactory\" +app_update 1690800 -beta public validate +quit
            Group=ubuntu
            KillSignal=SIGINT
            Restart=on-failure
            StandardOutput=journal
            User=ubuntu
            WorkingDirectory=$GS_ROOT/satisfactory

        [Install]
            WantedBy=multi-user.target" | tee "/etc/systemd/system/satisfactory.service"

        sed -i 's/^ *//g' "/etc/systemd/system/satisfactory.service"

        systemctl enable satisfactory.service --now
        systemctl restart satisfactory.service
    fi

    echo "INFO: Restart Satisfactory service"
    systemctl status satisfactory.service
fi

echo "INFO: ...done."
