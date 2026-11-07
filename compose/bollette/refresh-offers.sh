#!/bin/bash
# Aggiorna le offerte dal Portale Offerte (open data) e i prezzi storici PUN/PSV.
# Pianificalo una volta a settimana da OMV: System > Scheduled tasks.
set -euo pipefail

URL="http://localhost:8090"
LOG="/var/log/bollette_refresh.log"

echo "$(date): aggiornamento offerte avviato" >> "$LOG"
curl -fsS --max-time 300 -X POST "$URL/offers/import-arera" -o /dev/null >> "$LOG" 2>&1
echo "$(date): aggiornamento offerte completato" >> "$LOG"
truncate -s 1M "$LOG"
