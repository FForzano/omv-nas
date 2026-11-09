#!/bin/bash

# ===== CONFIGURAZIONE =====
LOG_FILE="/var/log/nas_transcode_$(date +%Y%m%d_%H%M%S).log"
CRF=20
AUDIO_BITRATE="160k"
PRESET="medium"
DELETE_ORIGINALS=false  # CAMBIA in true per CANCELLARE gli MKV dopo

# Conta totali MKV da processare
TOTAL_MKV=$(find . -name "*.mkv" | wc -l)
PROCESSED=0

echo "=== TRASCODIFICA NAS - $(date) ===" | tee -a "$LOG_FILE"
echo "MKV totali: $TOTAL_MKV | CRF:$CRF | Preset:$PRESET | Delete:$DELETE_ORIGINALS" | tee -a "$LOG_FILE"

# Conferma cancellazione se abilitata
if [ "$DELETE_ORIGINALS" = true ]; then
    read -p "CONFERMI CANCELLAZIONE MKV dopo MP4? (s/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        DELETE_ORIGINALS=false
        echo "Cancellazione disabilitata." | tee -a "$LOG_FILE"
    fi
fi

# Funzione principale
process_dir() {
    local dir="$1"
    echo "📁 $dir" | tee -a "$LOG_FILE"
    cd "$dir" || return
    
    for f in *.mkv; do
        [ -f "$f" ] || continue
        ((PROCESSED++))
        
        mp4="${f%.*}.mp4"
        
        # SKIP se MP4 esiste E ha dimensione > 100MB (file valido)
        if [ -f "$mp4" ] && [ $(stat -c%s "$mp4" 2>/dev/null || echo 0) -gt 100000000 ]; then
            echo "  ⏭️  SKIP $f (MP4 esiste: $(du -h "$mp4" | cut -f1)) [$PROCESSED/$TOTAL_MKV]" | tee -a "$LOG_FILE"
            continue
        fi
        
        # 1. ESTRAI SOTTOTITOLI
        echo "  🔤 Subs $f..." | tee -a "$LOG_FILE"
        ffprobe -loglevel error -select_streams s -show_entries stream=index:stream_tags=language,title -of csv=p=0 "$f" 2>/dev/null | while IFS=, read -r idx lang title; do
            [ -n "$lang" ] || lang="unknown"
            [ -n "$title" ] || title="sub"
            clean_name=$(echo "${f%.*}_${lang}_${title}.srt" | sed 's/[^a-zA-Z0-9._-]/_/g')
            ffmpeg -y -loglevel quiet -i "$f" -map 0:$idx "$clean_name" && \
            echo "     ✓ $clean_name"
        done
        
        # 2. TRANSCODIFICA
        echo "  🎥 Conv $f -> $mp4... [$PROCESSED/$TOTAL_MKV]" | tee -a "$LOG_FILE"
        if ffmpeg -i "$f" \
            -map 0:v:0 -map 0:a:0 \
            -c:v libx264 -preset "$PRESET" -crf "$CRF" \
            -c:a aac -b:a "$AUDIO_BITRATE" \
            -movflags +faststart -sn \
            -y "$mp4" 2>>"$LOG_FILE"; then
            
            echo "  ✅ $mp4 CREATO ($(du -h "$mp4" | cut -f1))" | tee -a "$LOG_FILE"
            
            # 3. CANCELLA ORIGINALE (se abilitato)
            if [ "$DELETE_ORIGINALS" = true ]; then
                rm -f "$f" && echo "  🗑️  MKV $f ELIMINATO" | tee -a "$LOG_FILE" || echo "  ❌ Errore cancellazione $f"
            fi
        else
            echo "  ❌ FALIMENTO $f - vedi log" | tee -a "$LOG_FILE"
        fi
    done
    cd - >/dev/null
}

# ESECUZIONE
export -f process_dir
export LOG_FILE CRF AUDIO_BITRATE PRESET DELETE_ORIGINALS TOTAL_MKV PROCESSED
find . -type d -exec bash -c 'process_dir "$0"' {} \;

echo "=== COMPLETATO: $PROCESSED/$TOTAL_MKV ===" | tee -a "$LOG_FILE"
