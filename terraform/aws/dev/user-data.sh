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

echo "INFO: Starting user-data.sh ..."

# # reset FS resources
# mkdir -p /opt/lanordie/gameserver/ || true
# rm /opt/lanordie/gameserver/installer.sh || true

# # copy installer.sh from S3 bucket
# s3 cp "$BUCKET_ARN":/installer.sh /opt/lanordie/gameserver/installer.sh
# chmod +x /opt/lanordie/gameserver/installer.sh

# # execution installer.sh REGION PA_TITAN_CRED_ARN
# # shellcheck disable=SC2269
# sudo /opt/lanordie/gameserver/installer.sh "$REGION" "$PA_TITAN_CRED_ARN"

echo "INFO: ...done."
--//--
