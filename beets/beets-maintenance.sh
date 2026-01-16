#!/bin/bash
# This script performs an incremental import of the music library,
# adding any new files to the database without removing existing entries. 
# It is intended to be run daily to keep the database updated with new additions.
PATH=/home/nas-master/beets-venv/bin:$PATH
MUSIC_DIR="/srv/dev-disk-by-uuid-d7e795e1-d44f-4d78-acc2-be119ba2dca3/Musica"

cd "$MUSIC_DIR" || exit 1
beet import . --incremental -m
beet duplicates
beet lyrics
beet replaygain