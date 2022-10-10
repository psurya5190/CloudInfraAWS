#!/bin/bash
set -e

# Bash helper script to download and verify external binaries to GitHub Action Runner
# Args:
# 1. URL of bin download
# 2. URL of shasum256 txt download
# 3. Name of the bin (i.e. tfsec)
##
# ex: ./dw_check_bin.sh https://github.com/tfsec/tfsec/releases/download/v0.40.0/tfsec-linux-amd64 https://github.com/tfsec/tfsec/releases/download/v0.40.0/tfsec_checksums.txt tfsec 
# - Downloads tfsec v0.40.0 to /usr/local/bin and confirms its existance

## CLI Flags
bin_url=${1}
sha256_url=${2}
bin_actual_name=${3}

if [[ -z ${bin_url} ]] || [[ -z ${sha256_url} ]] || [[ -z ${bin_actual_name} ]]; then
    echo "::error ::Passed wrong number of parameters in script call, please try again."
    exit 1
fi

## Temp Vars
bin_dw_name=$(basename ${bin_url})
shasum_file=$(basename ${sha256_url})
bin_dw_loc="/tmp/${bin_dw_name}"
shasum_dw_loc="/tmp/${shasum_file}"

# Download needed files
wget -q -O ${bin_dw_loc} ${bin_url}
wget -q -O ${shasum_dw_loc} ${sha256_url}

# Shasum checker
cd /tmp/
shasum -c --ignore-missing ${shasum_dw_loc} || (echo "::error ::sha256 of ${bin_actual_name} does not match with official download, please try again." && exit 1)
cd -

if [[ "${bin_dw_name##*.}" == "zip" ]]; then
    # If the file is a zip, we extract it and move it to the proper location
    zip_contents=( $(unzip -Z -1 ${bin_dw_loc}) )
    for curr_file in "${zip_contents[@]}"; do
        filename=$(basename ${curr_file})
        if [ $(echo ${bin_actual_name} | grep -c ${filename}) -eq 1 ]; then
            unzip -q ${bin_dw_loc} -d /tmp/ && rm ${bin_dw_loc}
            mv -f /tmp/${filename} /usr/local/bin/${bin_actual_name}
            break
        fi
    done
elif [[ "${bin_dw_name}" =~ .tar.gz$ ]]; then
    # If the file is a gzipped tar, we extract only the bin from it and move
    # it to the proper location
    tar -C /tmp/ -xvzf ${bin_dw_loc} ${bin_actual_name}
    mv -f /tmp/${bin_actual_name} /usr/local/bin/${bin_actual_name}
else
    # If the bin is just a bin on download, we just move it to the proper location
    mv -f ${bin_dw_loc} /usr/local/bin/${bin_actual_name}
fi

# Confirm bin works
chmod +x /usr/local/bin/${bin_actual_name} || (echo "Unable to find ${bin_actual_name}, please check if the provided download link contains said file." && exit 1)
${bin_actual_name} --version