
#!/bin/bash

set -Eeuo pipefail

# Configuration
DB_NAME="assignment_db"
PROJECT_DIR="/var/www/html/ssb-digital"
BACKUP_DIR="$PROJECT_DIR/backups"

# Timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Backup filenames
DB_BACKUP="$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.sql"
APP_BACKUP="$BACKUP_DIR/application_${TIMESTAMP}.tar.gz"

# Create backup directory
mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"
umask 077

# Temporary files
DB_TEMP=$(mktemp "$BACKUP_DIR/.db_XXXXXX")
APP_TEMP=$(mktemp "$BACKUP_DIR/.app_XXXXXX")

cleanup() {
    rm -f "$DB_TEMP" "$APP_TEMP"
}

trap cleanup EXIT

echo "Starting complete backup..."

# 1. Database backup
echo "Backing up database..."

mysqldump \
    --defaults-extra-file="$HOME/.my.cnf" \
    --single-transaction \
    "$DB_NAME" > "$DB_TEMP"

if [ ! -s "$DB_TEMP" ]; then
    echo "ERROR: Database backup is empty."
    exit 1
fi

mv "$DB_TEMP" "$DB_BACKUP"
chmod 600 "$DB_BACKUP"

echo "Database backup completed."

# 2. Application files backup
echo "Backing up application files..."

tar -czf "$APP_TEMP" \
    --exclude='./backups' \
    --exclude='./.git' \
    -C "$PROJECT_DIR" .

if [ ! -s "$APP_TEMP" ]; then
    echo "ERROR: Application backup is empty."
    exit 1
fi

mv "$APP_TEMP" "$APP_BACKUP"
chmod 600 "$APP_BACKUP"

echo "Application backup completed."

# 3. Verify the newly created backups
echo "Verifying backups..."

bash "$PROJECT_DIR/verify_backup.sh" "$DB_BACKUP"

echo "Backup verification completed successfully."

# 4. Delete backups older than seven days
echo "Cleaning old backups..."

find "$BACKUP_DIR" \
    -maxdepth 1 \
    -type f \
    \( -name "${DB_NAME}_*.sql" -o -name "application_*.tar.gz" \) \
    -mmin +10080 \
    -delete

echo "Old backups cleaned successfully."

# 4. Display results
echo "--------------------------------"
echo "BACKUP COMPLETED SUCCESSFULLY"
echo "Database: $DB_BACKUP"
echo "Application: $APP_BACKUP"
echo "--------------------------------"
