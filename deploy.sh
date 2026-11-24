#!/bin/bash

set -euo pipefail

SOURCE_DIR="/var/www/html/ssb-digital/"
DEPLOY_DIR="/var/www/html/ssb-digital-deploy/"

echo "Starting deployment..."

rsync -avh --itemize-changes \
    --exclude='.git/' \
    --exclude='.env' \
    --exclude='*.log' \
    --exclude='backups/' \
    --exclude='*.bak' \
    --exclude='config/database.php' \
    --exclude='*.sql' \
    --exclude='*.tar.gz' \
    --exclude='deploy.sh' \
    "$SOURCE_DIR" "$DEPLOY_DIR"

echo "Verifying deployment..."

diff -qr \
    --exclude='.git' \
    --exclude='.env' \
    --exclude='*.log' \
    --exclude='backups' \
    --exclude='*.bak' \
    --exclude='config/database.php' \
    --exclude='*.sql' \
    --exclude='*.tar.gz' \
    --exclude='deploy.sh' \
    "$SOURCE_DIR" "$DEPLOY_DIR"

echo "Deployment completed successfully!"


