#!/bin/bash

set -euo pipefail

LOG_FILE="./deploy.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# --------------------------------------------------
# 1. Validate arguments
# --------------------------------------------------

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <repo_directory> <branch> <deploy_directory>"
    exit 1
fi

REPO_DIR="$1"
BRANCH="$2"
DEPLOY_DIR="$3"

# --------------------------------------------------
# 2. Validate repository directory
# --------------------------------------------------

if [ ! -d "$REPO_DIR" ]; then
    log "ERROR: Directory does not exist: $REPO_DIR"
    exit 1
fi

# --------------------------------------------------
# 3. Validate Git repository
# --------------------------------------------------

if ! git -C "$REPO_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    log "ERROR: Not a Git repository: $REPO_DIR"
    exit 1
fi

log "INFO: Git repository validated: $REPO_DIR"

# --------------------------------------------------
# 4. Validate remote origin
# --------------------------------------------------

if ! git -C "$REPO_DIR" remote get-url origin >/dev/null 2>&1; then
    log "ERROR: Remote origin is not configured"
    exit 1
fi

log "INFO: Remote origin is configured"

# --------------------------------------------------
# 5. Check remote accessibility
# --------------------------------------------------

if ! git -C "$REPO_DIR" ls-remote origin >/dev/null 2>&1; then
    log "ERROR: Remote origin is not reachable or accessible"
    exit 1
fi

log "INFO: Remote origin is reachable"

# --------------------------------------------------
# 6. Check branch exists on remote
# --------------------------------------------------

if ! git -C "$REPO_DIR" ls-remote --heads origin "$BRANCH" >/dev/null 2>&1; then
    log "ERROR: Branch not found on remote: $BRANCH"
    exit 1
fi

log "INFO: Remote branch validated: $BRANCH"

# --------------------------------------------------
# 7. Fetch branch
# --------------------------------------------------

if ! git -C "$REPO_DIR" fetch origin "$BRANCH"; then
    log "ERROR: Failed to fetch branch: $BRANCH"
    exit 1
fi

log "INFO: Successfully fetched branch: $BRANCH"

# --------------------------------------------------
# 8. Checkout branch
# --------------------------------------------------

if ! git -C "$REPO_DIR" checkout "$BRANCH"; then
    log "ERROR: Failed to checkout branch: $BRANCH"
    exit 1
fi

log "INFO: Successfully checked out branch: $BRANCH"

# --------------------------------------------------
# 9. Pull latest changes
# --------------------------------------------------

if ! git -C "$REPO_DIR" pull --ff-only origin "$BRANCH"; then
    log "ERROR: Git pull failed"
    exit 1
fi

log "INFO: Repository updated successfully"

# --------------------------------------------------
# 10. Prepare deployment directories
# --------------------------------------------------

mkdir -p "$DEPLOY_DIR/releases"

log "INFO: Deployment directories ready"

# --------------------------------------------------
# 11. Remember currently deployed release
# --------------------------------------------------

PREVIOUS_RELEASE=$(readlink -f "$DEPLOY_DIR/current" 2>/dev/null || true)

if [ -n "$PREVIOUS_RELEASE" ]; then
    log "INFO: Previous release: $PREVIOUS_RELEASE"
else
    log "INFO: No previous release found"
fi

# --------------------------------------------------
# 12. Create new release
# --------------------------------------------------

TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

RELEASE_DIR="$DEPLOY_DIR/releases/$TIMESTAMP"

mkdir -p "$RELEASE_DIR"

log "INFO: Created release directory: $RELEASE_DIR"

# --------------------------------------------------
# 13. Deploy files
# --------------------------------------------------

if ! cp -r "$REPO_DIR"/* "$RELEASE_DIR/"; then
    log "ERROR: Failed to copy application files"
    rm -rf "$RELEASE_DIR"
    exit 1
fi

log "INFO: Application files deployed to: $RELEASE_DIR"

# --------------------------------------------------
# 14. Switch current release
# --------------------------------------------------

ln -sfn "$RELEASE_DIR" "$DEPLOY_DIR/current"

log "INFO: Current release switched to: $RELEASE_DIR"

# --------------------------------------------------
# 15. Health check
# --------------------------------------------------

log "INFO: Running application health check"

if curl -fsS http://localhost:8080/health >/dev/null; then

    log "INFO: Health check passed"
    log "INFO: Deployment successful"

else

    log "ERROR: Health check failed"

    # --------------------------------------------------
    # 16. Rollback
    # --------------------------------------------------

    if [ -n "$PREVIOUS_RELEASE" ]; then

        log "INFO: Starting rollback"

        ln -sfn "$PREVIOUS_RELEASE" "$DEPLOY_DIR/current"

        log "INFO: Rolled back to: $PREVIOUS_RELEASE"

    else

        log "ERROR: No previous release available for rollback"

    fi

    exit 1
fi

log "INFO: Deployment process completed successfully"

exit 0