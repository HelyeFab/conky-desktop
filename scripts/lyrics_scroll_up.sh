#!/bin/bash
CACHE_DIR="$HOME/.config/conky/lyrics"
OFFSET_FILE="$CACHE_DIR/scroll_offset.txt"
LYRICS_FILE="$CACHE_DIR/lyrics.txt"
MANUAL_FILE="$CACHE_DIR/manual_scroll.txt"
STEP=3

[ ! -f "$LYRICS_FILE" ] && exit 0

OFFSET=$(cat "$OFFSET_FILE" 2>/dev/null || echo "0")
OFFSET=$((OFFSET - STEP))
[ "$OFFSET" -lt 0 ] && OFFSET=0

echo "$OFFSET" > "$OFFSET_FILE"
echo "$(date +%s)" > "$MANUAL_FILE"
