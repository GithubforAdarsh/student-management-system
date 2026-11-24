#!/bin/bash

set -Eeuo pipefail

PROJECT_DIR="/var/www/html/ssb-digital"
BACKUP_DIR="$PROJECT_DIR/backups"
DB_NAME="assignment_db"

echo "=================================="
echo " SSB DIGITAL BACKUP VERIFICATION"
echo "=================================="

# 1. Find latest database backup
DB_BACKUP="${1:-$(find "$BACKUP_DIR" -maxdepth 1 -name "${DB_NAME}_*.sql" -type f | sort | tail -n 1)}"

if [[ -z "$DB_BACKUP" || ! -s "$DB_BACKUP" ]]; then
    echo "FAIL: Database backup missing or empty."
    exit 1
fi

echo "PASS: Database backup exists."

# 2. Verify SQL structure and data
if grep -q 'CREATE TABLE' "$DB_BACKUP" &&
   grep -q 'INSERT INTO' "$DB_BACKUP"; then
    echo "PASS: SQL structure and data found."
else
    echo "FAIL: SQL structure or data missing."
    exit 1
fi

# 3. Find matching application archive
TIMESTAMP=$(basename "$DB_BACKUP" \
    | sed "s/${DB_NAME}_//; s/\\.sql$//")

APP_BACKUP="$BACKUP_DIR/application_${TIMESTAMP}.tar.gz"

if [[ ! -s "$APP_BACKUP" ]]; then
    echo "FAIL: Matching application backup missing."
    exit 1
fi

echo "PASS: Application archive exists."

# 4. Check gzip integrity
if gzip -t "$APP_BACKUP"; then
    echo "PASS: Gzip integrity verified."
else
    echo "FAIL: Archive integrity error."
    exit 1
fi

# 5. Check essential application files
for FILE in \
    "./index.php" \
    "./add_student.php" \
    "./edit_student.php" \
    "./delete_student.php" \
    "./includes/header.php" \
    "./includes/footer.php"
do
    if tar -tzf "$APP_BACKUP" | grep -Fx "$FILE"; then
        echo "PASS: $FILE"
    else
        echo "FAIL: $FILE missing."
        exit 1
    fi
done

echo "=================================="
echo " BACKUP VERIFICATION SUCCESSFUL"
echo "=================================="
