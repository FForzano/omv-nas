#!/bin/bash
# bollette_gdrive.sh
set -euo pipefail

BACKUP_ROOT="gdrive_crypt:bollette"
LOG="/var/log/backup_bollette.log"
DATE=$(date +%Y%m%d_%H%M%S)
DATA_DIR="/srv/dev-disk-by-uuid-d7e795e1-d44f-4d78-acc2-be119ba2dca3/appdata/bollette/data"
CONTAINER="bollette"

echo "$(date): Backup bollette avviato" | tee -a "$LOG"

# === DATABASE ===
# Istantanea coerente con l'API di backup di SQLite (l'app può essere in uso)
echo "Istantanea DB SQLite" >> "$LOG" 2>&1
docker exec "$CONTAINER" python -c \
  "import sqlite3; s=sqlite3.connect('/data/bollette.db'); d=sqlite3.connect('/data/bollette.snapshot.db'); s.backup(d); d.close()"
rclone copyto "$DATA_DIR/bollette.snapshot.db" "$BACKUP_ROOT/db/bollette_$DATE.db" --log-file="$LOG"
rm -f "$DATA_DIR/bollette.snapshot.db"

# === PDF delle bollette ===
rclone mkdir "$BACKUP_ROOT/old"
rclone mkdir "$BACKUP_ROOT/old/$DATE"
rclone sync "$DATA_DIR/pdf" "$BACKUP_ROOT/pdf/" \
  --backup-dir "$BACKUP_ROOT/old/$DATE" \
  --log-file="$LOG"

echo "Backup bollette OK" >> "$LOG" 2>&1

echo "Pulizia db e old >30gg" >> "$LOG" 2>&1
rclone delete "$BACKUP_ROOT/db/" --min-age 30d --log-file="$LOG" --ignore-errors || true
rclone delete "$BACKUP_ROOT/old/" --min-age 30d --rmdirs --log-file="$LOG" --ignore-errors || true

echo "Backup bollette completato" | tee -a "$LOG"
truncate -s 10M "$LOG"
