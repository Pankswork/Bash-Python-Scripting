#!/bin/bash

set -euo pipefail

LOG_FILE="./service-monitor.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

if [ "$#" -ne 1 ];then
    log "Usage: $0 <service-name>"
    exit 1;
fi

SERVICE="$1"

if systemctl is-active "$SERVICE"; then
    log "$SERVICE is running"
    exit 0
else
    log "$SERVICE is not running, Attempting restart"

    sudo systemctl restart "$SERVICE" 
    
    if systemctl is-active --quiet "$SERVICE"; then
        log "$SERVICE restarted successfully"
        exit 0
    else
        log "Failed to restart $SERVICE"
        exit 1
    fi
fi