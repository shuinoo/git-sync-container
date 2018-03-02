#!/bin/bash


source /etc/container_environment.sh


function check_variable {
    variable_name=$1
    if [ ! -z "${!variable_name}" ]; then
        echo "${variable_name} found..." 
    else  
        if [ "$2" == "required" ]; then
            echo "Required environment variable '${variable_name}' missing. Unable to proceed."
            exit 1
        else
            echo "Optional environment variable '${variable_name}' missing. Continuing..."
            return 0
        fi
    fi
}


check_variable "GIT_REPO_URL" rquired
check_variable "DESTINATION_DIRECTORY" required
check_variable "GIT_REPO_BRANCH"
check_variable "GIT_HOST"
check_variable "CHOWN_USER"
check_variable "CHOWN_GROUP"


# This is in here incase the SSH host key changes.
if [[ ! -z "${GIT_HOST}" ]]; then
    ssh-keyscan -t rsa "${GIT_HOST}" > /root/.ssh/known_hosts
fi

TEMP_DIR=$(mktemp -d)

if [[ ! -z "${GIT_REPO_BRANCH}" ]]; then
    git clone --depth 1 "${GIT_REPO_URL}" -b "${GIT_REPO_BRANCH}" "${TEMP_DIR}" 
else
    git clone --depth 1 "${GIT_REPO_URL}" "${TEMP_DIR}" 
fi

if [[ ! -z "${CHOWN_USER}" ]]; then
    if [[ ! -z "${CHOWN_GROUP}" ]]; then
        chown -R ${CHOWN_USER}:${CHOWN_GROUP} "${TEMP_DIR}"
    else
        chown -R ${CHOWN_USER} "${TEMP_DIR}"
    fi
fi

rsync -avzh --delete "${TEMP_DIR}" "${DESTINATION_DIRECTORY}"

rm -rf "${TEMP_DIR}"