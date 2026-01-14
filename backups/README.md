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

## Note
- Nextcloud's backup script set the service in `manteinance`. It will be unusable
until the backup is concluded 
- all backups are progressive (they upload only differences) but the first time
  can require long times.