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

#!/bin/bash -ex

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "INFO: Starting user-data.sh ..."

echo "INFO: Set passed in ARGs to ENV VARs"

# shellcheck disable=SC2269 Pass variables to runtime ENV VAR
BUCKET_ID="${BUCKET_ID}"

# shellcheck disable=SC2269 Pass variables to runtime ENV VAR
INSTALLER_DIR_PATH="${INSTALLER_DIR_PATH}"

# shellcheck disable=SC2269 Pass variables to runtime ENV VAR
PA_TITAN_CRED_ARN="${PA_TITAN_CRED_ARN}"

# shellcheck disable=SC2269 Pass variables to runtime ENV VAR
REGION="${REGION}"

# Copy installer.sh to local FS
mkdir -p "${INSTALLER_DIR_PATH}" || exit 1
cd "${INSTALLER_DIR_PATH}" || exit 1
aws s3 cp "s3://${BUCKET_ID}/installer.sh" .
chmod +x "./installer.sh"

# Init logic

echo "INFO: Execution installer.sh"
# shellcheck disable=SC2269
./installer.sh \
    --BUCKET_ID "${BUCKET_ID}" \
    --INSTALLER_DIR_PATH "${INSTALLER_DIR_PATH}" \
    --PA_TITAN_CRED_ARN "${PA_TITAN_CRED_ARN}" \
    --REGION "${REGION}"

echo "INFO: ...done with user-data.sh."
--//--
