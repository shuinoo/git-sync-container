# git-sync-container

### Kubernetes Init command example:
```yaml
command: ["/bin/bash"]
args: ["-x", "-c", "/opt/wait_for_initial_sync.sh && echo 'do whatever else you need to do here'"]
```

## Todo List:
- Option to configure the 'lock file' used to wait for the initial synchronization to complete.
- Option to keep the git repo to save on network downloads
- Optional Force Overwriting.
- Option to use two directories and symlink swapping instead of tmpdir and Rsync
- Option to just sync git directly in the destination directory.
- More Documentation.
