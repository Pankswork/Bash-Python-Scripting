#!/bin/bash

set -euo pipefail

LOG_FILE="./ssh-multi-server.log"
CONNECT_TIMEOUT=5

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <server-file>"
    exit 1
fi

SERVER_FILE="$1"

if [ ! -f "$SERVER_FILE" ]; then
    log "ERROR: Server file does not exist: $SERVER_FILE"
    exit 1
fi

SUCCESSFUL=0
FAILED=0

while read -r SERVER; do

    # Skip blank lines and comments
    if [[ -z "$SERVER" || "$SERVER" == \#* ]]; then
        continue
    fi

    log "Checking server: $SERVER"

    if ssh -o ConnectTimeout="$CONNECT_TIMEOUT" "$SERVER" "hostname && uptime"; then
        log "SUCCESS: $SERVER is reachable"
        SUCCESSFUL=$((SUCCESSFUL + 1))
    else
        log "ERROR: SSH failed for $SERVER"
        FAILED=$((FAILED + 1))
    fi

done < "$SERVER_FILE" 

log "INFO: Successful servers: $SUCCESSFUL"
log "INFO: Failed servers: $FAILED"

if (( FAILED == 0 )); then
    log "INFO: All servers checked successfully"
    exit 0
else
    log "ERROR: One or more servers failed"
    exit 1
fi