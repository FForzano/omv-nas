#!/bin/bash
PATH=/home/nas-master/beets-venv/bin:$PATH
MUSIC_DIR="/srv/dev-disk-by-uuid-d7e795e1-d44f-4d78-acc2-be119ba2dca3/Musica"

cd "$MUSIC_DIR" || exit 1
beet import . --incremental
beet move
beet lyrics
beet duplicates
beet replaygain