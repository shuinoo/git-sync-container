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


check_variable "ENVKEY"
check_variable "ENVKEY_SSH_KEY_VARIABLE"
check_variable "CRON_SCHEDULE"
check_variable "PERFORM_INITIAL_SYNC"


if [[ ! -z "${ENVKEY}" ]]; then
    if [[ ! -z "${ENVKEY_SSH_KEY_VARIABLE}" ]]; then
        eval $(envkey-source) 
        eval ENVKEY_SSH_PRIVATE_KEY="\$$ENVKEY_SSH_KEY_VARIABLE"
        echo "${ENVKEY_SSH_PRIVATE_KEY}" | sed 's/\(-----BEGIN RSA PRIVATE KEY-----\|-----END RSA PRIVATE KEY-----\|[^ ]\{60,64\}\)\( \)/\1 \n/g' > /root/.ssh/id_rsa
        chmod 600 /root/.ssh/id_rsa
    fi
fi


if [[ ! -z "${CRON_SCHEDULE}" ]]; then
    printf "Creating Cron Job... "
    
    echo "${CRON_SCHEDULE} /opt/git_sync.sh 2>&1 | /usr/bin/logger -t git_sync" > /opt/cron_job_file
    crontab /opt/cron_job_file
    
    echo "Done."
fi


if [[ ! -z "${PERFORM_INITIAL_SYNC}" ]]; then
    if [ "${PERFORM_INITIAL_SYNC}" = true ]; then
        echo "Performing initial synchronization..."
        /opt/git_sync.sh
        echo "Initial synchronization Complete!"
    fi
fi


echo
echo "Git Sync Setup Complete !"
echo
