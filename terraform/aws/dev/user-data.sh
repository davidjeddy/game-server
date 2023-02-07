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
PA_TITAN_CRED_ARN="${PA_TITAN_CRED_ARN}"

# shellcheck disable=SC2269 Pass variables to runtime ENV VAR
REGION="${REGION}"

# shellcheck disable=SC2269 Pass variables to runtime ENV VAR
BUCKET_ID="${BUCKET_ID}"

# shellcheck disable=SC2269 Pass variables to runtime ENV VAR
INSTALLER_DIR_PATH="${INSTALLER_DIR_PATH}"

# Init logic

echo "INFO: ENV VAR check"
printenv | sort

echo "INFO: Installing system services."
apt-get install -y \
    htop \
    unzip

echo "INFO: Reset FS resources."
rm -rf "${INSTALLER_DIR_PATH}" || true
mkdir -p "${INSTALLER_DIR_PATH}" || true

echo "INFO: Copy install archives and script from S3 bucket to EC2 instance."
aws s3 ls "s3://${BUCKET_ID}/" --recursive --human-readable --summarize
aws s3 cp "s3://${BUCKET_ID}/" "${INSTALLER_DIR_PATH}/" --recursive

chmod +x "${INSTALLER_DIR_PATH}/installer.sh"

echo "INFO: Change into ${INSTALLER_DIR_PATH} dir."
cd "${INSTALLER_DIR_PATH}" || exit

echo "INFO: Execution installer.sh with REGION PA_TITAN_CRED_ARN"
# shellcheck disable=SC2269
./installer.sh --REGION "${REGION}" --PA_TITAN_CRED_ARN "${PA_TITAN_CRED_ARN}"

echo "INFO: ...done with user-data.sh."
--//--
