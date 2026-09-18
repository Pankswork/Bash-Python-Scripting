#!/bin/bash

set -euo pipefail

LOG_FILE="./backup.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source-path> <backup-path>"
    exit 1
fi

SOURCE="$1"
BACKUP_DIR="$2"

TEMP_FILE=$(mktemp)

log "Created temporary file: $TEMP_FILE"

cleanup() {
    if [ -n "${TEMP_FILE:-}" ]; then
        rm -f "$TEMP_FILE"
    fi    
    log "INFO: Cleanup completed"
}

trap cleanup EXIT

log "Starting backup process for $SOURCE to $BACKUP_DIR"

if [ ! -d "$SOURCE" ]; then
    log "ERROR: Source directory does not exist: $SOURCE"
    exit 1
fi

if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    log "Created destination directory: $BACKUP_DIR"
fi

TIMESTAMP=$(date '+%Y-%m-%d_%H%M%S')
SOURCE_NAME=$(basename "$SOURCE")

BACKUP_FILE="${BACKUP_DIR}/${SOURCE_NAME}_${TIMESTAMP}.tar.gz"

if tar -czf "$BACKUP_FILE" "$SOURCE"; then
    log "INFO: Backup created successfully"
else
    log "ERROR: Backup failed"
    exit 1
fi

if [ -f "$BACKUP_FILE" ]; then
    log "INFO: Backup verified: $BACKUP_FILE"
else
    log "ERROR: Backup file was not created"
    exit 1
fi

log "INFO: Backup process completed successfully"

