#!/bin/bash
echo 
echo "Running Initial Git Synchronization..."
set -x
/opt/git_sync.sh 2>&1 | /usr/bin/logger -t initial_git_sync
set +x
echo "Initial Git Synchronization Complete!"
echo
touch /opt/initial_sync_complete