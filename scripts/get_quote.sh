#!/bin/bash
CACHE_FILE="$HOME/.config/conky/quote_cache.txt"

# Fetch a new quote from the API
response=$(curl -s --max-time 5 "https://zenquotes.io/api/random" 2>/dev/null)

if [ -n "$response" ] && echo "$response" | grep -q '"q"'; then
    quote=$(echo "$response" | sed 's/.*"q":"\([^"]*\)".*/\1/')
    author=$(echo "$response" | sed 's/.*"a":"\([^"]*\)".*/\1/')
    echo "\"${quote}\"" | fold -s -w 50 > "$CACHE_FILE"
    echo "- ${author}" >> "$CACHE_FILE"
fi

# Display cached quote (fallback if API fails)
if [ -f "$CACHE_FILE" ]; then
    cat "$CACHE_FILE"
else
    echo "\"The only way to do great work is to love what you do.\""
    echo "- Steve Jobs"
fi
