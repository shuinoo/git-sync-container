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


echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo ' Starting Git Synchronization Script'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'


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

echo "--------------------------------"
echo "Starting git clone..." 
echo "--------------------------------"

# Construct git clone command arguments.
git_clone_args=()
if [[ ! -z "${VERBOSE}" ]]; then git_clone_args+=(--progress --verbose); fi
git_clone_args+=(--depth 1 "${GIT_REPO_URL}")
if [[ ! -z "${GIT_REPO_BRANCH}" ]]; then git_clone_args+=(-b "${GIT_REPO_BRANCH}"); fi
git_clone_args+=("${TEMP_DIR}")

# Perform the git clone
(set -x; git clone "${git_clone_args[@]}")

if [ -d "${TEMP_DIR}" ]; then

    echo "--------------------------------"
    echo "Git Clone Complete!"
    echo '\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/'
    echo '||||||||||||||||||||||||||||||||'
    echo '/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\'
    echo "Chowning files..."


    if [[ ! -z "${CHOWN_USER}" ]]; then
        if [[ ! -z "${CHOWN_GROUP}" ]]; then
            (set -x; chown -R ${CHOWN_USER}:${CHOWN_GROUP} "${TEMP_DIR}")
        else
            (set -x; chown -R ${CHOWN_USER} "${TEMP_DIR}")
        fi
    fi


    echo "Chown Complete!"
    echo '\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/'
    echo '||||||||||||||||||||||||||||||||'
    echo '/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\'
    echo "Rsyncing files into destination directory..."
    echo "--------------------------------"

    # Ensure the directory exists before using it.
    (set -x; mkdir -p "${DESTINATION_DIRECTORY}")

    # Construct rsync arguments.
    rsync_args=(-azh --delete --recursive)
    if [[ ! -z "$VERBOSE" ]]; then rsync_args+=(-v); fi
    rsync_args+=("${TEMP_DIR}"/* "${DESTINATION_DIRECTORY}")

    # Perform the rsync.
    (set -x; rsync "${rsync_args[@]}")

    echo "--------------------------------"
    echo "Rsync Complete!"
    echo '\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/'
    echo '||||||||||||||||||||||||||||||||'
    echo '/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\'

    (set -x; rm -rf "${TEMP_DIR}")

else
    echo "--------------------------------"
    echo "Git Clone Failed, unable to continue this syncronization attempt!"
    echo "Halting without performing any additional work."
    script_failed=true
fi

if [ "$script_failed" = true ]; then
    echo '================================================'
    echo ' Git Sync Failed'
    echo '================================================'
    exit 1
else
    echo '================================================'
    echo ' Git Sync Complete'
    echo '================================================'
fi