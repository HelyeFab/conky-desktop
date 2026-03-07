#!/bin/bash
CONKY_DIR="$HOME/.config/conky"
# Fetch new Pokemon
rm -f "$CONKY_DIR/pokemon/last_fetch"
"$CONKY_DIR/get_pokemon.sh"
# Restart the widget to show new data
pkill -f "conky.*pokemon.conf"
sleep 0.5
conky -d -c "$CONKY_DIR/pokemon.conf"
