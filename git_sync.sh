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

echo
echo "Starting git clone..." 
echo "--------------------------------"

# TODO: Option to keep the git repo to save on network downloads
# TODO: Optional Force Overwriting.  
# TODO: Option to use two directories and symlink swapping instead of tmpdir and Rsync
# TODO: Option to just sync git directly in the destination directory.
# TODO: Option to turn off the debug output.
# TODO: Documentation.

# Construct git clone command arguments.
git_clone_args=()
if [[ ! -z "${VERBOSE}" ]]; then git_clone_args+=(--progress --verbose); fi
git_clone_args+=(--depth 1 "${GIT_REPO_URL}")
if [[ ! -z "${GIT_REPO_BRANCH}" ]]; then git_clone_args+=(-b "${GIT_REPO_BRANCH}"); fi
git_clone_args+=("${TEMP_DIR}")

git clone "${git_clone_args[@]}"

# if [[ ! -z "${GIT_REPO_BRANCH}" ]]; then
#     git clone --progress --verbose --depth 1 "${GIT_REPO_URL}" -b "${GIT_REPO_BRANCH}" "${TEMP_DIR}" 
# else
#     git clone --progress --verbose --depth 1 "${GIT_REPO_URL}" "${TEMP_DIR}" 
# fi

echo "--------------------------------"
echo "Git Clone Complete!"
echo '\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/'
echo '||||||||||||||||||||||||||||||||'
echo '/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\'
echo "Chowning files..."

if [[ ! -z "${CHOWN_USER}" ]]; then
    if [[ ! -z "${CHOWN_GROUP}" ]]; then
        chown -R ${CHOWN_USER}:${CHOWN_GROUP} "${TEMP_DIR}"
    else
        chown -R ${CHOWN_USER} "${TEMP_DIR}"
    fi
fi

echo "Chown Complete!"
echo '\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/'
echo '||||||||||||||||||||||||||||||||'
echo '/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\'
echo "Rsyncing files into destination directory..."
echo "--------------------------------"

# Ensure the directory exists before using it.
mkdir -p ${DESTINATION_DIRECTORY}
rsync -avzh --delete "${TEMP_DIR}" "${DESTINATION_DIRECTORY}"

echo "--------------------------------"
echo "Rsync Complete!"
echo '\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/'
echo '||||||||||||||||||||||||||||||||'
echo '/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\'

rm -rf "${TEMP_DIR}"

echo '================================'
echo ' Git Sync Complete'
echo '================================'
