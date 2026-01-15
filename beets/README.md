# Beets configuration
This `README.md` explain how to configure `Beets` tool for automatially
discovering of music metadata and lyrics, and structuring data folder.

## Installation 
1. Install `beets` utility
```bash
sudo apt update
sudo apt install beets python3-pip ffmpeg
pip3 install beets[lyrics] --user  # Plugin lyrics + extra
```

## Configuration
1. Create config file's father directories
```bash
mkdir -p ~/.config/beets
```

2. copy the `config.yaml` file in it
```bash
scp beets/config.yaml your_user@your_ip:~/.config/beets
```

## Create a cron job
1. Open OMV web interface and go to `System > Scheduled Tasks`
2. Create two cronjobs running the following command once a day:
```bash
/usr/local/bin/beet import "/srv/dev-disk-by-uuid-d7e795e1-d44f-4d78-acc2-be119ba2dca3/Musica" --incremental --quiet >> /var/log/beets-import.log 2>&1
/usr/local/bin/beet lyrics "*" >> /var/log/beets-lyrics.log 2>&1
```