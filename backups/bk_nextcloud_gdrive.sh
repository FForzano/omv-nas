#!/bin/bash
# backup_dati_gdrive.sh - SOLO dati utente + DB dump (NO downtime/config)
set -euo pipefail

BACKUP_ROOT="gdrive_crypt:nextcloud"
LOG="/var/log/backup_nextcloud.log"
DATE=$(date +%Y%m%d_%H%M%S)
PATH_TO_BACKUP="/tmp"

echo "$(date): Backup nextcloud avviato" | tee -a "$LOG"

# === NEXTCLOUD ===
echo "Nextcloud maintenance ON" >> "$LOG" 2>&1
docker exec nextcloud occ maintenance:mode --on >>"$LOG" 2>&1

# DB (single-transaction = crash-safe)
DUMP_NAME="nc_db_$DATE.sql.gz"
docker exec nextcloud_mariadb mariadb-dump --single-transaction -u nextcloud -pnextcloudpass123 nextcloud | gzip > "$PATH_TO_BACKUP/$DUMP_NAME"
rclone copy "$PATH_TO_BACKUP/$DUMP_NAME" "$BACKUP_ROOT/dump/" --progress --log-file="$LOG"
rm "$PATH_TO_BACKUP/$DUMP_NAME"

echo "Backup DB Nextcloud OK" >> "$LOG" 2>&1

echo "Backup folders Nextcloud" >> "$LOG" 2>&1
rclone sync "/srv/dev-disk-by-uuid-d7e795e1-d44f-4d78-acc2-be119ba2dca3/appdata/nextcloud/data" "$BACKUP_ROOT/folders/data" \
  --backup-dir "$BACKUP_ROOT/old/$DATE" \
  --progress --log-file="$LOG" \
  --drive-pacer-min-sleep 250ms \
  --drive-pacer-burst 400 \
  --checkers 4 \
  --fast-list

rclone mkdir "$BACKUP_ROOT/old"
rclone mkdir "$BACKUP_ROOT/old/$DATE"
rclone sync "/srv/dev-disk-by-uuid-d7e795e1-d44f-4d78-acc2-be119ba2dca3/appdata/nextcloud/config" "$BACKUP_ROOT/folders/config" \
  --backup-dir "$BACKUP_ROOT/old/$DATE" \
  --progress --log-file="$LOG" \
  --checkers 4 \
  --drive-pacer-min-sleep 250ms \
  --drive-pacer-burst 400 \
  --fast-list

docker exec nextcloud occ maintenance:mode --off >>"$LOG" 2>&1
echo "Nextcloud maintenance OFF" >> "$LOG" 2>&1

rclone delete "$BACKUP_ROOT/old/" --min-age 7d --rmdirs --log-file="$LOG" --ignore-errors || true

echo "Backup Nextcloud OK" >> "$LOG" 2>&1
truncate -s 10M "$LOG"