#!/bin/bash
# This script performs an incremental import of the music library,
# adding any new files to the database without removing existing entries. 
# It is intended to be run daily to keep the database updated with new additions.
PATH=/home/nas-master/beets-venv/bin:$PATH
MUSIC_DIR="/srv/dev-disk-by-uuid-d7e795e1-d44f-4d78-acc2-be119ba2dca3/Musica"

cd "$MUSIC_DIR" || exit 1

echo "Starting non-incremental import of new music files..."
beet import -I .
echo "Import completed."

echo "Starting moving files to organized structure..."
beet move
echo "Move completed."

# Remove directories containing no media files (flacs, mp3s, etc.). They may contain other files (covers, etc.) but beets doesn't care about those.
echo "Removing empty directories and other non-media files..."
find . -mindepth 1 -type d -depth | while read dir; do
    if [ -z "$(find "$dir" -type f \( -iname '*.mp3' -o -iname '*.flac' -o -iname '*.m4a' -o -iname '*.ogg' -o -iname '*.wav' -o -iname '*.aac' -o -iname '*.wma' -o -iname '*.ape' -o -iname '*.alac' -o -iname '*.aiff' -o -iname '*.dff' -o -iname '*.dsf' -o -iname '*.opus' -o -iname '*.mpc' -o -iname '*.tta' -o -iname '*.wv' \) 2>/dev/null)" ]; then
        rm -rf "$dir" 2>/dev/null && echo "Removed empty directory: $dir"
    fi
done
echo "Empty directory removal completed."

echo "Calculating and removing duplicates..."
beet duplicates -d
echo "Duplicates removal completed."

echo "Fetching lyrics for tracks..."
beet lyrics
echo "Lyrics fetching completed."

echo "Calculating replaygain values..."
beet replaygain
echo "Replaygain calculation completed."