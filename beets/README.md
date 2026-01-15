# Beets configuration
This `README.md` explain how to configure `Beets` tool for automatially
discovering of music metadata and lyrics, and structuring data folder.

## Installation 
1. Install `beets` utility
```bash
sudo apt update
sudo apt install beets python3-pip ffmpeg
```
2. Create a `venv` for beets and activate it
```bash
python3 -m venv ~/beets-venv
source ~/beets-venv/bin/activate
```
3. Install lyrics plugin and deactivate the venv
```bash
pip install beets[lyrics]  # Plugin lyrics + extra
deactivate
```

## Configuration
1. Create config file's father directories
```bash
mkdir -p ~/.config/beets
```

2. copy the `config.yaml` file in it
```bash
scp beets/config.yaml your_user@your_ip:~/.config/beets/
```

## Copy the script
1. Copy the `beets-maintenance.sh` file in your user bin folder
```bash
scp beets/beets-maintenance.sh your_user@your_ip:~/scripts/
```
2. Ensure execution priviledges to the script
```bash
chmod +x ~/scripts/beets-maintenance.sh
```

## Create a cron job
1. Open OMV web interface and go to `System > Scheduled Tasks`
2. Create a cronjob running the script `beets-maintenance.sh`: