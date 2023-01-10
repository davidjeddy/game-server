#!/bin/bash -ex

# -----
# Application activision toggle
# -----

ENABLE_FACTORIO=true
ENABLE_KSP=true
ENABLE_PA_TITANS=true
ENABLE_SATISFACTORY=true
ENABLE_SATISFACTORY_EXPERIMENTAL=true

# -----
# Application specific VARs
# -----

TITANS_UPGRADE=true

# -----
# K/V's passed in from ec2_instance.tf
# Key/Values are passed in via instance data.template_file.user_data invocation
# -----

# shellcheck disable=SC2269 Pass variables to runtime ENV VAR
PA_TITAN_CRED_ARN="${2}"

# shellcheck disable=SC2269 Pass variables to runtime ENV VAR
REGION="${1}"

# -----
# File system assignments
# -----

FACTORIO_FS_UUID="728348fc-0937-417a-a41d-aebf800ee662"
KSP_FS_UUID="4c7b6e43-e3eb-46cf-88db-ce92a027c093"
PA_TITANS_FS_UUID="488fa00f-a1c1-4177-8bfd-e81d05fb3f95"
SATISFACTORY_FS_UUID="5fcf53ed-23af-4de1-8fb8-f9ab59e42bc6"
SATISFACTORY_EXPERIMENTAL_FS_UUID="0fab4de1-05ee-4399-928f-ea4a4d1fd690"

# -----
# System configuration
# -----

exec > >(tee /var/log/installer.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "INFO: Have set ENV VARS in installer.sh..."

# -----
# Application install, update, configuration, and execution
# -----

# -----
# Factorio (~/factorio)
# -----

if [[ $ENABLE_FACTORIO == true ]]
then
    echo "INFO: Mount Kerbal Space Program EBS volume"
    mkdir -p /home/ubuntu/factorio || true

    # check if the FS is already listed in /etc/fstab
    if [[ ! $(grep -rnw '/etc/fstab' -e "$FACTORIO_FS_UUID") ]]
    then
        echo "UUID=$FACTORIO_FS_UUID /home/ubuntu/factorio ext4 defaults,errors=remount-ro 0 1" >> /etc/fstab
        mount -a
    fi

    echo "INFO: /etc/fstab contents"
    cat /etc/fstab

    if [[ ! -f /home/ubuntu/factorio/bin/x64/factorio ]]
    then
        echo "INFO: Installing Factorio dedicated server"
        curl -L https://www.factorio.com/get-download/1.1.61/headless/linux64 -o factorio_headless_x64_1.1.61.tar.xz
        tar -xJf factorio_headless_x64_1.1.61.tar.xz
        cp -rf factorio /home/ubuntu
        mkdir -p /home/ubuntu/factorio/saves
        /home/ubuntu/factorio/bin/x64/factorio --create /home/ubuntu/factorio/saves/lanordie.zip
    fi

    echo "INFO: Resetting Factorio dir ownership"
    chown ubuntu:ubuntu -R /home/ubuntu/factorio

    if [[ ! -f "/etc/systemd/system/factorio.service" ]]
    then
        echo "INFO: Create system service for Factorio"
        echo -e "\
        [Unit]
        Description=Factorio Dedicated Server service
        After=network.target

        [Service]
        ExecStart=/home/ubuntu/factorio/bin/x64/factorio --start-server-load-latest --server-settings /home/ubuntu/factorio/data/server-settings.json --console-log /home/ubuntu/factorio/console.log
        Group=ubuntu
        KillSignal=SIGINT
        Restart=always
        Restart=on-failure
        StandardOutput=journal
        User=ubuntu
        User=ubuntu
        WorkingDirectory=/home/ubuntu/factorio

        [Install]
        WantedBy=multi-user.target" | tee "/etc/systemd/system/factorio.service"

        sed -i 's/^ *//g' "/etc/systemd/system/factorio.service"

        systemctl enable factorio.service --now
        systemctl restart factorio.service
    fi

    echo "INFO: Factorio service status"
    systemctl status factorio.service
fi

# -----
# KSP (~/ksp)
# -----

if [[ $ENABLE_KSP == true ]]
then
    echo "INFO: Mount Kerbal Space Program EBS volume"
    mkdir -p /home/ubuntu/ksp || true

    # check if the FS is already listed in /etc/fstab
    if [[ ! $(grep -rnw '/etc/fstab' -e "$KSP_FS_UUID") ]]
    then
        echo "UUID=$KSP_FS_UUID /home/ubuntu/ksp ext4 defaults,errors=remount-ro 0 1" >> /etc/fstab
        mount -a
    fi

    echo "INFO: /etc/fstab contents"
    cat /etc/fstab

    if [[ ! -f /home/ubuntu/factorio/bin/x64/factorio ]]
    then
        echo "INFO: Installing KSP DMPServer dedicated server and DMPUpdater"
        curl -L  https://d-mp.org/builds/release/v0.3.8.3/DMPServer.zip -o DMPServer.zip
        unzip -u DMPServer.zip
        cd  DMPServer
        curl -L https://godarklight.privatedns.org/dmp/downloads/dmpupdater/DMPUpdater.exe -o DMPUpdater.exe
        mono DMPUpdater.exe >1 /dev/null
        cp -rf . /home/ubuntu/ksp
    fi

    echo "INFO: Resetting Kerbal Space Program dir ownership"
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
            ExecStart=mono /usr/share/ksp/DMPServer.exe
            Group=ubuntu
            KillSignal=SIGINT
            Restart=on-failure
            StandardOutput=journal
            User=ubuntu
            WorkingDirectory=/usr/share/ksp

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

# TODO we need the install commands for PA:Titans
# if [[ $ENABLE_PA_TITANS == true ]]
# then
#     echo "INFO: Mount Planetary Annihilation : Titans EBS volume"
#     mkdir -p /home/ubuntu/pa_titans || true

#     # check if the FS is already listed in /etc/fstab
#     if [[ ! $(grep -rnw '/etc/fstab' -e "$PA_TITANS_FS_UUID") ]]
#     then
#         echo "UUID=$PA_TITANS_FS_UUID /home/ubuntu/pa_titans ext4 defaults,errors=remount-ro 0 1" >> /etc/fstab
#         mount -a
#     fi

#     echo "INFO: /etc/fstab contents"
#     cat /etc/fstab

#     if [[ ! -f /home/ubuntu/pa_titans/PA/stable/server ]]
#     then
#         echo "INFO: Install Planetary Annihilation : Titans archive"
#         mkdir -p /home/ubuntu/pa_titans/stable
#         tar -xf /home/ubuntu/pa_titans/resources/PA_Linux_115872.tar.bz2 -C /home/ubuntu/pa_titans/stable --verbose
#     fi

#     echo "INFO: Resetting Planetary Annihilation : Titans dir ownership"
#     chown ubuntu:ubuntu -R /home/ubuntu/pa_titans

#     if [[ $TITANS_UPGRADE == true ]]
#     then
#         echo "INFO: Patching Planetary Annihilation : Titans from stable branch"
#         mkdir -p /home/ubuntu/.cache
#         XDG_CACHE_HOME=/home/ubuntu/.cache
#         export XDG_CACHE_HOME

#         # Key/Values are passed in via instance data.template_file.user_data invocation
#         # shellcheck disable=SC2086
#         go run /home/ubuntu/pa_titans/resources/papatcher.go \
#             --dir /home/ubuntu/pa_titans/PA/ \
#             --stream stable \
#             --update-only \
#             --username "$(aws secretsmanager get-secret-value --region $REGION --secret-id $PA_TITAN_CRED_ARN --query SecretString --output text | jq -r .username)" \
#             --password "$(aws secretsmanager get-secret-value --region $REGION --secret-id $PA_TITAN_CRED_ARN --query SecretString --output text | jq -r .password)"
#     fi

#     echo "INFO: Version of Planetary Annihilationvers : Titans is $(cat /home/ubuntu/pa_titans/PA/version.txt)"

#     if [[ ! -f "/etc/systemd/system/pa_titans.service" ]]
#     then
#         echo "INFO: Create system service for Planetary Annihilation : Titans"

#         mkdir -p "/home/ubuntu/pa_titans/download"
#         mkdir -p "/home/ubuntu/pa_titans/network"
#         mkdir -p "/home/ubuntu/pa_titans/output"

#         echo -e "\
#         [Unit]
#             After=syslog.target network.target nss-lookup.target network-online.target
#             Description=Planetary Annihilation : Titans dedicated server
#             Wants=network-online.target

#         [Service]
#             ExecStart=/home/ubuntu/pa_titans/PA/stable/server \
#                 --allow-lan \
#                 --game-mode \"PAExpansion1:config\" \
#                 --gameover-timeout 360 \
#                 --headless \
#                 --max-players 8 \
#                 --max-spectators 2 \
#                 --mt-enabled \
#                 --output-dir /home/ubuntu/pa_titans/output \
#                 --port 20545 \
#                 --replay-filename \"UTCTIMESTAMP\" \
#                 --replay-timeout 180 \
#                 --server-name \"LanOrDie_PA_Titans\"

#             Group=ubuntu
#             KillSignal=SIGINT
#             NoNewPrivileges=yes
#             PrivateDevices=yes
#             PrivateTmp=yes
#             ProtectControlGroups=yes
#             ProtectKernelModules=yes
#             ProtectKernelTunables=yes
#             Restart=on-failure
#             StandardOutput=journal
#             User=ubuntu
#             WorkingDirectory=/home/ubuntu/pa_titans/PA/stable/

#         [Install]
#             WantedBy=multi-user.target" | tee "/etc/systemd/system/pa_titans.service"

#         sed -i 's/^ *//g' "/etc/systemd/system/pa_titans.service"

#         systemctl enable pa_titans.service --now
#         systemctl restart pa_titans.service
#     fi

#     echo "INFO: Planetary Annihilation : Titans service status"
#     systemctl status pa_titans.service
# fi

# -----
# Satisfactory (~/.config/Epic/satisfactory)
# -----

if [[ $ENABLE_SATISFACTORY == true ]]
then
    echo "INFO: Mount Satisfactory EBS volume"
    mkdir -p /home/ubuntu/satisfactory || true

    # check if the FS is already listed in /etc/fstab
    if [[ ! $(grep -rnw '/etc/fstab' -e "$SATISFACTORY_FS_UUID") ]]
    then
        echo "UUID=$SATISFACTORY_FS_UUID /home/ubuntu/satisfactory ext4 defaults,errors=remount-ro 0 1" >> /etc/fstab
        mount -a
    fi

    echo "INFO: /etc/fstab contents"
    cat /etc/fstab

    if [[ ! -d /home/ubuntu/satisfactory/satisfactory ]]
    then
        echo "INFO: Install of Satisfactory Dedicated Server via steamcmd"
        mkdir -p /home/ubuntu/satisfactory/satisfactory
        # NOTE The order of arguments is important when using steamcmd via automation.
        sudo -u ubuntu /usr/games/steamcmd \
            +force_install_dir /home/ubuntu/satisfactory/satisfactory \
            +login anonymous \
            +app_update 1690800 \
            -beta public validate \
            +quit
    fi

    echo "INFO: Resetting Satisfactory dir ownership"
    chown ubuntu:ubuntu -R /home/ubuntu/satisfactory

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
            ExecStart=/home/ubuntu/satisfactory/satisfactory/FactoryServer.sh
            Group=ubuntu
            KillSignal=SIGINT
            Restart=on-failure
            StandardOutput=journal
            User=ubuntu
            WorkingDirectory=/home/ubuntu/satisfactory/satisfactory

        [Install]
            WantedBy=multi-user.target" | tee "/etc/systemd/system/satisfactory.service"

        sed -i 's/^ *//g' "/etc/systemd/system/satisfactory.service"

        systemctl enable satisfactory.service --now
        systemctl restart satisfactory.service
    fi

    echo "INFO: Satisfactory service status"
    systemctl status satisfactory.service
fi

# -----
# Satisfactory Experimental (~/.config/Epic/satisfactory_experimental)
# -----

if [[ $ENABLE_SATISFACTORY_EXPERIMENTAL == true ]]
then
    echo "INFO: Mount Satisfactory Experimental EBS volume"
    mkdir -p /home/ubuntu/satisfactory_experimental || true

    # check if the FS is already listed in /etc/fstab
    if [[ ! $(grep -rnw '/etc/fstab' -e "$SATISFACTORY_EXPERIMENTAL_FS_UUID") ]]
    then
        echo "UUID=$SATISFACTORY_EXPERIMENTAL_FS_UUID /home/ubuntu/satisfactory_experimental ext4 defaults,errors=remount-ro 0 1" >> /etc/fstab
        mount -a
    fi

    echo "INFO: /etc/fstab contents"
    cat /etc/fstab

    if [[ ! -d /home/ubuntu/satisfactory_experimental ]]
    then
        echo "INFO: Install of Satisfactory Experimental Dedicated Server via steamcmd"
        mkdir -p /home/ubuntu/satisfactory/satisfactory_experimental
        # NOTE The order of arguments is important when using steamcmd via automation.
        sudo -u ubuntu /usr/games/steamcmd \
            +force_install_dir /home/ubuntu/satisfactory_experimenta \
            +login anonymous \
            +app_update 1690800 \
            -beta experimental validate \
            +quit
    fi

    echo "INFO: Resetting Satisfactory Experimental dir ownership"
    chown ubuntu:ubuntu -R /home/ubuntu/satisfactory_experimental

    if [[ ! -f "/etc/systemd/system/satisfactory_experimental.service" ]]
    then
        echo "INFO: Create system service for Satisfactory Experimental"
        echo -e "\
        [Unit]
            After=syslog.target network.target nss-lookup.target network-online.target
            Description=Satisfactory Experimental dedicated server
            Wants=network-online.target

        [Service]
            Environment=\"LD_LIBRARY_PATH=./linux64\"
            ExecStart=/home/ubuntu/satisfactory_experimental/FactoryServer.sh
            Group=ubuntu
            KillSignal=SIGINT
            Restart=on-failure
            StandardOutput=journal
            User=ubuntu
            WorkingDirectory=/home/ubuntu/satisfactory_experimental

        [Install]
            WantedBy=multi-user.target" | tee "/etc/systemd/system/satisfactory_experimental.service"

        sed -i 's/^ *//g' "/etc/systemd/system/satisfactory_experimental.service"

        systemctl enable satisfactory_experimental.service --now
        systemctl restart satisfactory_experimental.service
    fi

    echo "INFO: Satisfactory Experimental service status"
    systemctl status satisfactory_experimental.service
fi

# create cron job to update and restart services once a week

echo "INFO: ...done."