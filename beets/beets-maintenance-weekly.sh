#!/bin/bash
# This script performs a full re-import of the music library,
# removing any deleted files from the database before re-importing.
# It is intended to be run weekly (or less) to ensure the database stays
# in sync with the actual files on disk.
# Execution time ~ 30-60 minutes depending on library size.
PATH=/home/nas-master/beets-venv/bin:$PATH
MUSIC_DIR="/srv/dev-disk-by-uuid-d7e795e1-d44f-4d78-acc2-be119ba2dca3/Musica"

cd "$MUSIC_DIR" || exit 1
beet remove -f
beet import . -m
beet duplicates
beet lyrics
beet replaygain