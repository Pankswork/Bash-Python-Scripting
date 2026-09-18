#!/bin/bash

set -euo pipefail

LOG_FILE="./log-cleanup.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <directory> <days>"
    exit 1
fi

DIRECTORY="$1"
DAYS="$2"

if [ ! -d "$DIRECTORY" ]; then
    log "ERROR: Directory does not exist: $DIRECTORY"
    exit 1
fi

if ! [[ "$DAYS" =~ ^[0-9]+$ ]]; then
    log "ERROR: Days must be a number"
    exit 1
fi

if (( DAYS < 1 )); then
    log "ERROR: Days must be greater than 0"
    exit 1
fi

log "INFO: Attempting cleanup of files older than $DAYS days in $DIRECTORY"

OLD_LOGS=$(find "$DIRECTORY" -type f -name "*.log" -mtime +"$DAYS")

if [[ -z "$OLD_LOGS" ]]; then
    log "INFO: No logs found to delete"
else
    find "$DIRECTORY" -type f -name "*.log" -mtime +"$DAYS" -delete
    log "INFO: Old log files deleted successfully"
fi   