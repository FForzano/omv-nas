# Bollette (confronto offerte luce/gas)

App web self-hosted che legge le bollette in PDF e dice se conviene cambiare offerta.
Codice e documentazione: <https://github.com/FForzano/lg-invoices-analyzer> (guida generale in `deploy/`).

## Installazione
1. Crea la cartella dati e dalle all'utente dei container (stesso di Navidrome, Nextcloud...):
   ```bash
   mkdir -p <appdata>/bollette/data && chown 1000:100 <appdata>/bollette/data
   ```
2. Sostituisci `CHANGE_TO_COMPOSE_DATA_PATH` nel compose con il percorso `appdata` (come per gli altri servizi).
3. Copia `example.env` in `.env` e imposta `SECRET_KEY` (`openssl rand -hex 32`).
4. Avvia: `docker compose up -d` (scarica l'immagine da GitHub). Interfaccia su `http://<ip-nas>:8090`.

## Note
- **Nessuna autenticazione**: lasciala solo in LAN, non esporla sul router.
- La cartella dati contiene database e PDF delle bollette (dati personali): è inclusa nel backup (`../../backups/bk_bollette_gdrive.sh`).
- Aggiornamento offerte: pianifica `refresh-offers.sh` una volta a settimana (OMV: *System > Scheduled tasks*).
- Aggiornamento dell'app: `docker compose pull && docker compose up -d` (le migrazioni del database sono automatiche). Fai prima un backup.
- La porta 8090 è libera; 8080 è di qBittorrent, 4533 di Navidrome, 446 di Nextcloud.
