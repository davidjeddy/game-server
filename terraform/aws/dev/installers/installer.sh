#!/bin/bash -ex

# -----
# Autor David J Eddy<me@davidjeddy.com>
# Example ./installer.sh --REGION "${REGION}" --PA_TITAN_CRED_ARN "${PA_TITAN_CRED_ARN}"
# Version 2.0.0
# -----

# -----
# Positional arguments provided by user-data.sh invocation
# -----

while [ $# -gt 0 ]; do
    if [[ $1 == "--help" ]]; then
        echo "INFO: Open the script, check the examples section."
        exit 0
    elif [[ $1 == "--"* ]]; then
        key="${1/--/}"
        declare "$key"="$2"
        shift
    fi
    shift
done

# Check the two required arguments are provided
if [[ -z $REGION ]]; then
    echo "ERR: Missing parameter --REGION"
    exit 1
elif [[ -z $PA_TITAN_CRED_ARN ]]; then
    echo "ERR: Missing parameter --PA_TITAN_CRED_ARN"
    exit 1
fi

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
# File system assignments
# -----

echo "INFO: SET local VARS"
FACTORIO_FS_UUID="728348fc-0937-417a-a41d-aebf800ee662"
KSP_FS_UUID="4c7b6e43-e3eb-46cf-88db-ce92a027c093"
PA_TITANS_FS_UUID="488fa00f-a1c1-4177-8bfd-e81d05fb3f95"
SATISFACTORY_FS_UUID="5fcf53ed-23af-4de1-8fb8-f9ab59e42bc6"
SATISFACTORY_EXPERIMENTAL_FS_UUID="0fab4de1-05ee-4399-928f-ea4a4d1fd690"

# -----
# Application install, update, configuration, and execution
# -----

echo "INFO: Create a tmp working dir to use as needed"
rm -rf "${INSTALLER_DIR_PATH}" || true
mkdir -p "${INSTALLER_DIR_PATH}" || exit 1
cd "${INSTALLER_DIR_PATH}" || exit 1

# -----
# Factorio (~/factorio)
# -----

if [[ $ENABLE_FACTORIO == true ]]
then
    echo "INFO: Mount Kerbal Space Program EBS volume"
    mkdir -p /home/ubuntu/factorio || true

    # check if the FS is already listed in /etc/fstab
    # shellcheck disable=SC2143
    if [[ ! $(grep -rnw '/etc/fstab' -e "$FACTORIO_FS_UUID") ]]
    then
        echo "UUID=$FACTORIO_FS_UUID /home/ubuntu/factorio ext4 defaults,errors=remount-ro 0 1" >> /etc/fstab
        mount -a
    fi

    echo "INFO: /etc/fstab contents"
    cat /etc/fstab

    if [[ ! -f /home/ubuntu/factorio/bin/x64/factorio ]]
    then
        echo "INFO: Install Factorio archive"
        cd "${INSTALLER_DIR_PATH}" || exit 1
        mkdir -p /home/ubuntu/factorio || exit 1

        aws s3 cp "s3://${BUCKET_ID}/factorio_headless_x64_1.1.74.tar.xz" .
        tar -xf "factorio_headless_x64_1.1.74.tar.xz" -C /home/ubuntu/pa_titans/stable

        cd "${INSTALLER_DIR_PATH}"/
        ./factorio --create /home/ubuntu/factorio/saves/lanordie.zip
        ls -la /home/ubuntu/factorio/saves
    fi

    echo "INFO: Resetting Factorio dir ownership"
    cd "$HOME" || exit 1
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
    # shellcheck disable=SC2143
    if [[ ! $(grep -rnw '/etc/fstab' -e "$KSP_FS_UUID") ]]
    then
        echo "UUID=$KSP_FS_UUID /home/ubuntu/ksp ext4 defaults,errors=remount-ro 0 1" >> /etc/fstab
        mount -a
    fi

    echo "INFO: /etc/fstab contents"
    cat /etc/fstab

    if [[ ! -f /home/ubuntu/factorio/bin/x64/factorio ]]
    then
        echo "INFO: Install KSP base"
        cd "${INSTALLER_DIR_PATH}" || exit 1
        mkdir -p "/home/ubuntu/ksp/" || exit 1

        echo "INFO: Copy KSP base archive"
        aws s3 cp "s3://${BUCKET_ID}/ksp-linux-1.12.5.zip" .
        unzip -oqq ksp-linux-1.12.5.zip /home/ubuntu/ksp/

        echo "INFO: Install KSP expansions"
        aws s3 cp "s3://${BUCKET_ID}/KSP-Breaking_Ground_Expansion-en-us-lin-1.7.1.zip" .
        unzip -oqq KSP-Breaking_Ground_Expansion-en-us-lin-1.7.1.zip -d /home/ubuntu/ksp

        aws s3 cp "s3://${BUCKET_ID}/KSP-Making_History_Expansion-en-us-lin-1.12.1.zip" .
        unzip -oqq KSP-Making_History_Expansion-en-us-lin-1.12.1.zip -d /home/ubuntu/ksp

        cd /home/ubuntu/ksp
        chmod +x ./dlc-bge-en-us.sh
        ./dlc-bge-en-us.sh
        chmod +x ./dlc-mhe-en-us.sh
        ./dlc-mhe-en-us.sh

        echo "INFO: Installing and update KSP DMPServer dedicated server and DMPUpdater"
        aws s3 cp "s3://${BUCKET_ID}/DMPServer.zip" .
        unzip -oqq DMPServer.zip -d /home/ubuntu/ksp

        cp -rf DMPModpackUpdater.exe /home/ubuntu/ksp
        mono DMPModpackUpdater.exe

        cd /home/ubuntu/ksp
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
            ExecStart=mono /home/ubuntu/ksp/DMPServer/DMPServer.exe
            Group=ubuntu
            KillSignal=SIGINT
            Restart=on-failure
            StandardOutput=journal
            User=ubuntu
            WorkingDirectory=/home/ubuntu/ksp

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
if [[ $ENABLE_PA_TITANS == true ]]
then
    echo "INFO: Mount Planetary Annihilation : Titans EBS volume"
    mkdir -p /home/ubuntu/pa_titans || true

    # check if the FS is already listed in /etc/fstab
    # shellcheck disable=SC2143
    if [[ ! $(grep -rnw '/etc/fstab' -e "$PA_TITANS_FS_UUID") ]]
    then
        echo "UUID=$PA_TITANS_FS_UUID /home/ubuntu/pa_titans ext4 defaults,errors=remount-ro 0 1" >> /etc/fstab
        mount -a
    fi

    echo "INFO: /etc/fstab contents"
    cat /etc/fstab

    if [[ ! -f /home/ubuntu/pa_titans/PA/stable/server ]]
    then
        # source https://store.planetaryannihilation.net/Download/Install?titleId=4&sessionTicket=7065387651658097800
        echo "INFO: Install Planetary Annihilation : Titans archive"
        cd "${INSTALLER_DIR_PATH}" || exit 1
        mkdir -p /home/ubuntu/pa_titans/stable || exit 1

        aws s3 cp "s3://${BUCKET_ID}/PA_Linux_116400.tar.bz2" .
        tar -xf PA_Linux_116400.tar.bz2 -C /home/ubuntu/pa_titans/stable
    fi

    if [[ $TITANS_UPGRADE == true ]]
    then
        # source https://service.planetaryannihilation.net/User/Login?titleId=4&redirectUrl=https://store.planetaryannihilation.net/Download/Install?titleId=4
        echo "INFO: Patching Planetary Annihilation : Titans from stable branch"
        mkdir -p /home/ubuntu/.cache
        XDG_CACHE_HOME=/home/ubuntu/.cache
        export XDG_CACHE_HOME

        # Key/Values are passed in via instance data.template_file.user_data invocation
        # shellcheck disable=SC2086
        curl -sL https://raw.githubusercontent.com/planetary-annihilation/papatcher/master/papatcher.go -o "${INSTALLER_DIR_PATH}"/papatcher.go
        chmod +x papatcher.go
        go run "${INSTALLER_DIR_PATH}"/papatcher.go \
            --dir /home/ubuntu/pa_titans/pa/ \
            --stream stable \
            --update-only \
            --username "$(aws secretsmanager get-secret-value --region "$REGION" --secret-id "$PA_TITAN_CRED_ARN" --query SecretString --output text | jq -r .username)" \
            --password "$(aws secretsmanager get-secret-value --region "$REGION" --secret-id "$PA_TITAN_CRED_ARN" --query SecretString --output text | jq -r .password)"
    fi

    echo "INFO: Update PA: Titans"
    echo "INFO: Resetting Planetary Annihilation : Titans dir ownership"
    chown ubuntu:ubuntu -R /home/ubuntu/pa_titans

    echo "INFO: Version of Planetary Annihilationvers : Titans is $(cat /home/ubuntu/pa_titans/PA/version.txt)"

    if [[ ! -f "/etc/systemd/system/pa_titans.service" ]]
    then
        echo "INFO: Create system service for Planetary Annihilation : Titans"

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
    echo "INFO: Mount Satisfactory EBS volume"
    mkdir -p /home/ubuntu/satisfactory/stable || true

    # check if the FS is already listed in /etc/fstab
    if [[ ! $(grep -rnw '/etc/fstab' -e "$SATISFACTORY_FS_UUID") ]]
    then
        echo "UUID=$SATISFACTORY_FS_UUID /home/ubuntu/satisfactory/stable ext4 defaults,errors=remount-ro 0 1" >> /etc/fstab
        mount -a
    fi

    echo "INFO: /etc/fstab contents"
    cat /etc/fstab

    if [[ ! -f /home/ubuntu/satisfactory/stable/FactoryServer.sh ]]
    then
        echo "INFO: Install of Satisfactory Dedicated Server via steamcmd"
        # NOTE The order of arguments is important when using steamcmd via automation.
        sudo -u ubuntu /usr/games/steamcmd \
            +force_install_dir /home/ubuntu/satisfactory/stable \
            +login anonymous \
            +app_update 1690800 \
            -beta public validate \
            +quit
    fi

    echo "INFO: Resetting Satisfactory dir ownership"
    chown ubuntu:ubuntu -R /home/ubuntu/satisfactory/stable

    if [[ ! -f "/etc/systemd/system/satisfactory_stable.service" ]]
    then
        echo "INFO: Create system service for Satisfactory"
        echo -e "\
        [Unit]
            After=syslog.target network.target nss-lookup.target network-online.target
            Description=Satisfactory stable dedicated server
            Wants=network-online.target

        [Service]
            Environment=\"LD_LIBRARY_PATH=./linux64\"
            ExecStart=/home/ubuntu/satisfactory/stable/FactoryServer.sh
            Group=ubuntu
            KillSignal=SIGINT
            Restart=on-failure
            StandardOutput=journal
            User=ubuntu
            WorkingDirectory=/home/ubuntu/satisfactory/stable

        [Install]
            WantedBy=multi-user.target" | tee "/etc/systemd/system/satisfactory_stable.service"

        sed -i 's/^ *//g' "/etc/systemd/system/satisfactory_stable.service"

        systemctl enable satisfactory_stable.service --now
        systemctl restart satisfactory_stable.service
    fi

    echo "INFO: Satisfactory service status"
    systemctl status satisfactory_stable.service
fi

# -----
# Satisfactory Experimental (~/.config/Epic/satisfactory_experimental)
# -----

if [[ $ENABLE_SATISFACTORY_EXPERIMENTAL == true ]]
then
    echo "INFO: Mount Satisfactory Experimental EBS volume"
    mkdir -p /home/ubuntu/satisfactory/experimental || true

    # check if the FS is already listed in /etc/fstab
    if [[ ! $(grep -rnw '/etc/fstab' -e "$SATISFACTORY_EXPERIMENTAL_FS_UUID") ]]
    then
        echo "UUID=$SATISFACTORY_EXPERIMENTAL_FS_UUID /home/ubuntu/satisfactory/experimental ext4 defaults,errors=remount-ro 0 1" >> /etc/fstab
        mount -a
    fi

    echo "INFO: /etc/fstab contents"
    cat /etc/fstab

    if [[ ! -f /home/ubuntu/satisfactory/experimental/FactoryServer.sh ]]
    then
        echo "INFO: Install of Satisfactory Experimental Dedicated Server via steamcmd"
        # NOTE The order of arguments is important when using steamcmd via automation.
        sudo -u ubuntu /usr/games/steamcmd \
            +force_install_dir /home/ubuntu/satisfactory/experimental \
            +login anonymous \
            +app_update 1690800 \
            -beta experimental validate \
            +quit
    fi

    echo "INFO: Resetting Satisfactory Experimental dir ownership"
    chown ubuntu:ubuntu -R /home/ubuntu/satisfactory/experimental

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
            ExecStart=/home/ubuntu/satisfactory/experimental/FactoryServer.sh -Port=7778 -BeaconPort=15001 -ServerQueryPort=15778
            Group=ubuntu
            KillSignal=SIGINT
            Restart=on-failure
            StandardOutput=journal
            User=ubuntu
            WorkingDirectory=/home/ubuntu/satisfactory/experimental

        [Install]
            WantedBy=multi-user.target" | tee "/etc/systemd/system/satisfactory_experimental.service"

        sed -i 's/^ *//g' "/etc/systemd/system/satisfactory_experimental.service"

        systemctl enable satisfactory_experimental.service --now
        systemctl restart satisfactory_experimental.service
    fi

    echo "INFO: Satisfactory Experimental service status"
    systemctl status satisfactory_experimental.service
fi

# umount the S3 drive

# create cron job to update and restart services once a week

echo "INFO: ...done with installer.sh."
