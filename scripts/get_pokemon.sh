#!/bin/bash
CACHE_DIR="$HOME/.config/conky/pokemon"
INFO_FILE="$CACHE_DIR/info.txt"
SPRITE_FILE="$CACHE_DIR/sprite.png"

mkdir -p "$CACHE_DIR"

# Random Pokemon ID (Gen 1-9, 1025 total)
ID=$((RANDOM % 1025 + 1))

# Fetch Pokemon data
DATA=$(curl -s --max-time 10 "https://pokeapi.co/api/v2/pokemon/$ID" 2>/dev/null)
if [ -z "$DATA" ]; then
    echo "Failed to fetch" > "$INFO_FILE"
    exit 1
fi

NAME=$(echo "$DATA" | jq -r '.name' | sed 's/\b\(.\)/\u\1/g')
TYPES=$(echo "$DATA" | jq -r '[.types[].type.name] | map(. / "" | first |= ascii_upcase | add) | join(" / ")')
HP=$(echo "$DATA" | jq -r '.stats[] | select(.stat.name=="hp") | .base_stat')
ATK=$(echo "$DATA" | jq -r '.stats[] | select(.stat.name=="attack") | .base_stat')
DEF=$(echo "$DATA" | jq -r '.stats[] | select(.stat.name=="defense") | .base_stat')
SPATK=$(echo "$DATA" | jq -r '.stats[] | select(.stat.name=="special-attack") | .base_stat')
SPDEF=$(echo "$DATA" | jq -r '.stats[] | select(.stat.name=="special-defense") | .base_stat')
SPD=$(echo "$DATA" | jq -r '.stats[] | select(.stat.name=="speed") | .base_stat')
HEIGHT=$(echo "$DATA" | jq -r '.height')
WEIGHT=$(echo "$DATA" | jq -r '.weight')

# Convert height (decimetres) and weight (hectograms)
HEIGHT_M=$(awk "BEGIN {printf \"%.1f\", $HEIGHT/10}")
WEIGHT_KG=$(awk "BEGIN {printf \"%.1f\", $WEIGHT/10}")

# Download official artwork (high quality) and flatten transparency
SPRITE_URL="https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$ID.png"
SPRITE_RAW="$CACHE_DIR/sprite_raw.png"
curl -s --max-time 10 -o "$SPRITE_RAW" "$SPRITE_URL" 2>/dev/null
convert "$SPRITE_RAW" -background "#1a1a2e" -resize 160x160 -alpha remove -alpha off "$SPRITE_FILE" 2>/dev/null

# Write info file
cat > "$INFO_FILE" << EOF
#${ID}
${NAME}
${TYPES}
${HP}
${ATK}
${DEF}
${SPATK}
${SPDEF}
${SPD}
${HEIGHT_M}m
${WEIGHT_KG}kg
EOF
