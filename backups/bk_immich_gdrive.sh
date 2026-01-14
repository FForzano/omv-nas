#!/bin/bash
# immich_gdrive.sh
set -euo pipefail

BACKUP_ROOT="gdrive_crypt:immich"
LOG="/var/log/backup_immich.log"
DATE=$(date +%Y%m%d_%H%M%S)
PATH_TO_BACKUP="/tmp"
DB_USERNAME="immich"

echo "$(date): Backup immich avviato" | tee -a "$LOG"

# === IMMICH ===
echo "Dump DB PostgreSQL" >> "$LOG" 2>&1
DUMP_NAME="immich_db_$DATE.sql.gz"
docker exec -t immich_postgres pg_dumpall --clean --if-exists --username=${DB_USERNAME} | gzip > "${PATH_TO_BACKUP}/$DUMP_NAME"
rclone copy "${PATH_TO_BACKUP}/${DUMP_NAME}" "${BACKUP_ROOT}/dump/" --progress --log-file="$LOG"
rm "${PATH_TO_BACKUP}/${DUMP_NAME}"

# Upload (foto/video + thumbs/metadati)
rclone mkdir "$BACKUP_ROOT/old"
rclone mkdir "$BACKUP_ROOT/old/$DATE"
rclone sync "/srv/dev-disk-by-uuid-d7e795e1-d44f-4d78-acc2-be119ba2dca3/appdata/immich/upload" "$BACKUP_ROOT/upload/" \
  --backup-dir "$BACKUP_ROOT/old/$DATE" \
  --progress --log-file="$LOG" \
  --drive-pacer-min-sleep 100ms \
  --drive-pacer-burst 100 \
  --checkers 4

echo "Backup Immich OK" >> "$LOG" 2>&1

echo "Pulizia old >7gg" >> "$LOG" 2>&1
rclone delete "$BACKUP_ROOT/old/" --min-age 7d --rmdirs --log-file="$LOG"
