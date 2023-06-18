#!/usr/bin/env bash

set -eu -o pipefail

# check if the AWS CLI is installed
if ! command -v aws &> /dev/null; then
  echo "[error] AWS CLI is not installed"
  # exit 1
fi

# set the S3 bucket and file details
s3_bucket="${S3_BUCKET:-undefined}"
s3_object="${S3_OBJECT:-undefined}"

if [ "${s3_bucket}" == 'undefined' ]; then
  echo "[error] s3_bucket variable required"
  exit 1
fi
if [ "${s3_object}" == 'undefined' ]; then
  echo "[error] s3_object variable required"
  exit 1
fi

echo "[info] s3_bucket set to: ${s3_bucket}"
echo "[info] s3_object set to: ${s3_object}"

base_path='/tmp/assmble/downloads'
s3_object_path=$(dirname "${s3_object}")

# create temporary directory
mkdir -p "${base_path}/${s3_bucket}/${s3_object_path}"
# set the local destination for the downloaded file
binary_path="${base_path}/${s3_object}"
echo "[info] binary_path set to: ${binary_path}"

s3_path="s3://${s3_bucket}/${s3_object}"

# check if the file already exists locally
if [ -f "${binary_path}" ]; then
  echo "[info] file (${binary_path}) already exists - skipping download"
else
  echo "[info] file (${binary_path}) does not exists - downloading"

  # download the file from S3
  # check if the download was successful
  aws s3 cp "${s3_path}" "${binary_path}" || {
    echo "[error] failed to download file (${s3_path}) from S3"
    exit 1
  }

  echo "[info] file downloaded successfully"

  # make the downloaded file executable
  chmod +x "${binary_path}"
fi

# execute the binary file
"${binary_path}"
