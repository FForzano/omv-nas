# Backup scripts
This directory contains backup scripts to securely backup NAS data on remote
storages (like google drive).

## Google drive backup
Google drive backup scripts assume that the system has rclone configured as
described in the [official website](https://rclone.org/install/). You can also
(and it is suggested) configure an encryption for you data.

## How to use
To execute backups, you should create a cron task to execute the scripts, i.e.,
- copy the scripts in the NAS (e.g., in `/usr/bin`)
- from OMV web-interface, create a new scheduled task in `System > Scheduled
  task`

## Restore
To restore your data, follow the official guides:
- Nextcloud:
  [guide](https://docs.nextcloud.com/server/latest/admin_manual/maintenance/restore.html)
- Immich: [guide](https://docs.immich.app/administration/backup-and-restore/)
- Bollette: ferma il container, rimetti `bollette_<data>.db` come `bollette.db` e i PDF in `pdf/`
  dentro `appdata/bollette/data`, poi riavvia (vedi `compose/bollette/README.md`)

## Bollette
`bk_bollette_gdrive.sh` salva un'istantanea coerente del database SQLite e i PDF (dati personali: usa il
remoto cifrato `gdrive_crypt`). Conserva 30 giorni di versioni. Non mette il servizio in manutenzione.

## Note
- Nextcloud's backup script set the service in `manteinance`. It will be unusable
until the backup is concluded 
- all backups are progressive (they upload only differences) but the first time
  can require long times.