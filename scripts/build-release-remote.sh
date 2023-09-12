#!/bin/bash
set -e

# This script uses a remote docker daemon to perform the docker build.
# This is useful when using Apple Silicon Macs / Arm processors which are very slow to build x86/arm64 images.

# Requires $DOCKER_REMOTE be set in your .zshrc or env
[[ -z "$DOCKER_REMOTE" ]] && { echo "DOCKER_REMOTE env var not set" >&2; exit 1; }
    
echo "Setting remote DOCKER_HOST: $DOCKER_REMOTE"  
export DOCKER_TLS_VERIFY=1
export DOCKER_HOST=$DOCKER_REMOTE

# Perform Build
$(dirname $0)/"build-release.sh"

echo "Unsetting remote DOCKER_HOST"
unset DOCKER_TLS_VERIFY
unset DOCKER_HOST
