#! /bin/bash

# This script waits for the initial git repository synchronization to complete.

while : ;
do 
    [[ -f "/opt/initial_sync_complete" ]] && break
    echo "Waiting until initial sync completes..."
    sleep 1
done