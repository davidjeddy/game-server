Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"

#!/bin/bash -e

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "INFO: Starting user-data.sh ..."

echo "INFO: ENV VAR check"
printenv | sort

echo "INFO: reset FS resources"
mkdir -p /opt/lanordie/gameserver/ || true
rm /opt/lanordie/gameserver/installer.sh || true

echo "INFO: copy installer.sh from S3 bucket"
aws s3 ls s3://game-server-dev-installers-1dma --recursive --human-readable --summarize
aws s3 cp s3://game-server-dev-installers-1dma/installer.sh /opt/lanordie/gameserver/installer.sh
chmod +x /opt/lanordie/gameserver/installer.sh

echo "INFO: change into /opt/lanordie/gameserver/ dir"
cd "/opt/lanordie/gameserver/" || exit

echo "INFO: execution installer.sh with $REGION $PA_TITAN_CRED_ARN"
# shellcheck disable=SC2269
./installer.sh "$REGION" "$PA_TITAN_CRED_ARN"

echo "INFO: ...done."
--//--
