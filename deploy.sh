
#!/bin/bash

set -Eeuo pipefail

# Configuration
SOURCE_DIR="/var/www/html/ssb-digital"
DEPLOY_DIR="/var/www/html/ssb-digital-deploy"

# Default mode: dry-run
MODE="${1:---dry-run}"

case "$MODE" in
    --dry-run)
        DRY_RUN=true
        ;;
    --apply)
        DRY_RUN=false
        ;;
    *)
        echo "Usage: $0 [--dry-run|--apply]"
        exit 1
        ;;
esac

echo "=================================="
echo " SSB DIGITAL DEPLOYMENT"
echo "=================================="

# 1. Validate required directories
if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "ERROR: Source directory missing."
    exit 1
fi

if [[ ! -d "$DEPLOY_DIR" ]]; then
    echo "ERROR: Deployment directory missing."
    exit 1
fi

# 2. Validate required application files
REQUIRED_FILES=(
    "index.php"
    "config/database.php"
    "includes/header.php"
    "includes/footer.php"
)

for FILE in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$SOURCE_DIR/$FILE" ]]; then
        echo "ERROR: Required file missing: $FILE"
        exit 1
    fi
done

# 3. Preserve destination database configuration
if [[ ! -f "$DEPLOY_DIR/config/database.php" ]]; then
    echo "ERROR: Destination database configuration missing."
    exit 1
fi

# 4. Check required utility
if ! command -v rsync >/dev/null 2>&1; then
    echo "ERROR: rsync is not installed."
    exit 1
fi

# 5. Exclusions
EXCLUDES=(
    --exclude='.git/'
    --exclude='.env'
    --exclude='.env.*'
    --exclude='*.log'
    --exclude='logs/'
    --exclude='backups/'
    --exclude='*.bak'
    --exclude='config/database.php'
    --exclude='*.sql'
    --exclude='*.tar.gz'
    --exclude='deploy.sh'
)

# 6. Select execution mode
RSYNC_MODE=()

if [[ "$DRY_RUN" == true ]]; then
    RSYNC_MODE+=(--dry-run)
    echo "MODE: DRY RUN - No files will be copied."
else
    echo "MODE: ACTUAL DEPLOYMENT"
fi

echo "Source: $SOURCE_DIR/"
echo "Destination: $DEPLOY_DIR/"
echo

# 7. Execute rsync
rsync -avh --no-perms --itemize-changes \
    "${RSYNC_MODE[@]}" \
    "${EXCLUDES[@]}" \
    "$SOURCE_DIR/" "$DEPLOY_DIR/"

echo
echo "Rsync operation completed."

# 8. Verify synchronization
echo "Checking for remaining changes..."

rsync -avhn --no-perms --itemize-changes \
    "${EXCLUDES[@]}" \
    "$SOURCE_DIR/" "$DEPLOY_DIR/"

echo
echo "Deployment verification command completed."
