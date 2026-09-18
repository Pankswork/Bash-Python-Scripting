#!/bin/bash

set -euo pipefail

LOG_FILE="./disk-monitor.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <threshold>"
    exit 1
fi

THRESHOLD="$1"

if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]]; then
    echo "Error: Threshold must be a positive integer"
    exit 1
fi

if (( THRESHOLD < 1 || THRESHOLD > 100 )); then
    echo "Error: Threshold must be between 1 and 100"
    exit 1
fi

DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

if (( DISK_USAGE >= THRESHOLD )); then
    log "WARNING: $DISK_USAGE% of disk space is used"
    exit 1
else
    log "INFO: $DISK_USAGE% of disk space is used"
    exit 0
fi