#!/bin/bash
# Monitor playback status and show/hide nowplaying + lyrics conky widgets

CONKY_DIR="$HOME/.config/conky"
PLAYING=false

start_widgets() {
    if [ "$PLAYING" = false ]; then
        conky -d -c "$CONKY_DIR/nowplaying.conf"
        conky -d -c "$CONKY_DIR/lyrics.conf"
        PLAYING=true
    fi
}

stop_widgets() {
    if [ "$PLAYING" = true ]; then
        pkill -f "conky.*nowplaying.conf" 2>/dev/null
        pkill -f "conky.*lyrics.conf" 2>/dev/null
        PLAYING=false
    fi
}

# Check initial state
STATUS=$(playerctl status 2>/dev/null)
if [ "$STATUS" = "Playing" ]; then
    start_widgets
fi

# Watch for playback changes
playerctl -F status 2>/dev/null | while read -r STATUS; do
    if [ "$STATUS" = "Playing" ]; then
        start_widgets
    else
        stop_widgets
    fi
done
