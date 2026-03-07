#!/bin/bash
# Called by conky to refresh pokemon periodically
# Check if last fetch was more than 10 minutes ago
CACHE_DIR="$HOME/.config/conky/pokemon"
STAMP_FILE="$CACHE_DIR/last_fetch"

mkdir -p "$CACHE_DIR"

INTERVAL=600  # 10 minutes

if [ ! -f "$STAMP_FILE" ]; then
    NEED_FETCH=true
else
    LAST=$(cat "$STAMP_FILE")
    NOW=$(date +%s)
    ELAPSED=$((NOW - LAST))
    if [ "$ELAPSED" -ge "$INTERVAL" ]; then
        NEED_FETCH=true
    else
        NEED_FETCH=false
    fi
fi

if [ "$NEED_FETCH" = true ]; then
    /home/helye/.config/conky/get_pokemon.sh
    date +%s > "$STAMP_FILE"
fi
