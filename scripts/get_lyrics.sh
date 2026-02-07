#!/bin/bash
CACHE_DIR="$HOME/.config/conky/lyrics"
LYRICS_FILE="$CACHE_DIR/lyrics.txt"
SONG_FILE="$CACHE_DIR/current_song.txt"
OFFSET_FILE="$CACHE_DIR/scroll_offset.txt"
MANUAL_FILE="$CACHE_DIR/manual_scroll.txt"
LINES_TO_SHOW=16
SCROLL_STEP=3
WRAP_WIDTH=42
MANUAL_TIMEOUT=30

mkdir -p "$CACHE_DIR"

# Get current song info
ARTIST=$(playerctl metadata artist 2>/dev/null)
TITLE=$(playerctl metadata title 2>/dev/null)

# Nothing playing
if [ -z "$ARTIST" ] || [ -z "$TITLE" ]; then
    echo "Nothing playing..."
    rm -f "$SONG_FILE" "$LYRICS_FILE" "$OFFSET_FILE"
    exit 0
fi

SONG_KEY="${ARTIST}|${TITLE}"

# Check if song changed
CACHED_SONG=""
[ -f "$SONG_FILE" ] && CACHED_SONG=$(cat "$SONG_FILE")

if [ "$SONG_KEY" != "$CACHED_SONG" ]; then
    # New song — reset offset and fetch lyrics
    echo "0" > "$OFFSET_FILE"
    echo "$SONG_KEY" > "$SONG_FILE"

    # URL-encode artist and title
    ARTIST_ENC=$(printf '%s' "$ARTIST" | jq -sRr @uri)
    TITLE_ENC=$(printf '%s' "$TITLE" | jq -sRr @uri)

    LYRICS=""

    # Try lrclib.net exact match first
    RESPONSE=$(curl -s --max-time 5 "https://lrclib.net/api/get?artist_name=${ARTIST_ENC}&track_name=${TITLE_ENC}" 2>/dev/null)
    if [ -n "$RESPONSE" ] && echo "$RESPONSE" | jq -e '.plainLyrics' >/dev/null 2>&1; then
        LYRICS=$(echo "$RESPONSE" | jq -r '.plainLyrics // empty')
        if [ -z "$LYRICS" ]; then
            LYRICS=$(echo "$RESPONSE" | jq -r '.syncedLyrics // empty' | sed 's/^\[[0-9:.]*\] *//')
        fi
    fi

    # Try lrclib.net search (handles Japanese/non-Latin titles better)
    if [ -z "$LYRICS" ]; then
        QUERY_ENC=$(printf '%s' "$ARTIST $TITLE" | jq -sRr @uri)
        RESPONSE=$(curl -s --max-time 5 "https://lrclib.net/api/search?q=${QUERY_ENC}" 2>/dev/null)
        if [ -n "$RESPONSE" ] && echo "$RESPONSE" | jq -e '.[0]' >/dev/null 2>&1; then
            LYRICS=$(echo "$RESPONSE" | jq -r '.[0].plainLyrics // empty')
            if [ -z "$LYRICS" ]; then
                LYRICS=$(echo "$RESPONSE" | jq -r '.[0].syncedLyrics // empty' | sed 's/^\[[0-9:.]*\] *//')
            fi
        fi
    fi

    # Try j-lyric.net (Japanese lyrics database)
    if [ -z "$LYRICS" ]; then
        JLYRIC_PAGE=$(curl -s --max-time 5 -A "Mozilla/5.0" \
            "https://j-lyric.net/search.php?ct=2&ca=2&ka=${ARTIST_ENC}&kt=${TITLE_ENC}" 2>/dev/null)
        JLYRIC_URL=$(echo "$JLYRIC_PAGE" | grep -oP 'href="(https://j-lyric\.net/artist/a[^/]+/l[^"]*\.html)"' | head -1 | grep -oP 'https://[^"]*')
        if [ -n "$JLYRIC_URL" ]; then
            LYRICS=$(curl -s --max-time 5 -A "Mozilla/5.0" "$JLYRIC_URL" 2>/dev/null \
                | grep -oP '(?<=id="Lyric">).*?(?=</p>)' \
                | sed 's/<br[^>]*>/\n/g; s/<[^>]*>//g')
        fi
    fi

    # Try lyrics.ovh as final fallback
    if [ -z "$LYRICS" ]; then
        RESPONSE=$(curl -s --max-time 5 "https://api.lyrics.ovh/v1/${ARTIST_ENC}/${TITLE_ENC}" 2>/dev/null)
        if [ -n "$RESPONSE" ] && echo "$RESPONSE" | jq -e '.lyrics' >/dev/null 2>&1; then
            LYRICS=$(echo "$RESPONSE" | jq -r '.lyrics // empty')
        fi
    fi

    if [ -n "$LYRICS" ]; then
        echo "$LYRICS" | python3 ~/.config/conky/unicode_wrap.py "$WRAP_WIDTH" > "$LYRICS_FILE"
    else
        echo "No lyrics found for:" > "$LYRICS_FILE"
        echo "$TITLE" | python3 ~/.config/conky/unicode_wrap.py "$WRAP_WIDTH" >> "$LYRICS_FILE"
        echo "by $ARTIST" | python3 ~/.config/conky/unicode_wrap.py "$WRAP_WIDTH" >> "$LYRICS_FILE"
    fi
fi

# Display lyrics with auto-scroll
if [ ! -f "$LYRICS_FILE" ]; then
    echo "No lyrics found"
    exit 0
fi

TOTAL_LINES=$(wc -l < "$LYRICS_FILE")
OFFSET=$(cat "$OFFSET_FILE" 2>/dev/null || echo "0")

# Show a window of lines starting at offset
if [ "$TOTAL_LINES" -le "$LINES_TO_SHOW" ]; then
    # Short lyrics — show everything, no scrolling
    cat "$LYRICS_FILE"
else
    # Extract the window, wrapping around to top if needed
    REMAINING=$((TOTAL_LINES - OFFSET))
    if [ "$REMAINING" -ge "$LINES_TO_SHOW" ]; then
        sed -n "$((OFFSET + 1)),$((OFFSET + LINES_TO_SHOW))p" "$LYRICS_FILE"
    else
        # Show end of file + wrap to beginning
        sed -n "$((OFFSET + 1)),${TOTAL_LINES}p" "$LYRICS_FILE"
        NEED=$((LINES_TO_SHOW - REMAINING))
        sed -n "1,${NEED}p" "$LYRICS_FILE"
    fi

    # Advance offset for next cycle (skip if user scrolled recently)
    SKIP_ADVANCE=false
    if [ -f "$MANUAL_FILE" ]; then
        MANUAL_TIME=$(cat "$MANUAL_FILE")
        NOW=$(date +%s)
        ELAPSED=$((NOW - MANUAL_TIME))
        if [ "$ELAPSED" -lt "$MANUAL_TIMEOUT" ]; then
            SKIP_ADVANCE=true
        fi
    fi
    if [ "$SKIP_ADVANCE" = false ]; then
        NEXT_OFFSET=$(( (OFFSET + SCROLL_STEP) % TOTAL_LINES ))
        echo "$NEXT_OFFSET" > "$OFFSET_FILE"
    fi
fi
