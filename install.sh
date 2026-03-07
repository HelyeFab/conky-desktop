#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONKY_DIR="$HOME/.config/conky"
FONT_DIR="$HOME/.local/share/fonts"
AUTOSTART_DIR="$HOME/.config/autostart"

echo "=== Conky Desktop Widgets Installer ==="

# Install dependencies
echo "[1/7] Installing dependencies..."
sudo apt update -qq
sudo apt install -y conky-all playerctl jq curl imagemagick

# Install fonts
echo "[2/7] Installing fonts..."
mkdir -p "$FONT_DIR"
cp "$SCRIPT_DIR/fonts/"* "$FONT_DIR/"
fc-cache -f "$FONT_DIR"

# Copy configs
echo "[3/7] Installing Conky configs..."
mkdir -p "$CONKY_DIR"
cp "$SCRIPT_DIR/configs/"* "$CONKY_DIR/"
cp "$SCRIPT_DIR/scripts/get_quote.sh" "$CONKY_DIR/"
chmod +x "$CONKY_DIR/get_quote.sh"
cp "$SCRIPT_DIR/scripts/get_lyrics.sh" "$CONKY_DIR/"
chmod +x "$CONKY_DIR/get_lyrics.sh"
cp "$SCRIPT_DIR/scripts/lyrics_scroll.lua" "$CONKY_DIR/"
mkdir -p "$CONKY_DIR/lyrics"

# Pokemon widget scripts
echo "[4/7] Installing Pokemon widget..."
cp "$SCRIPT_DIR/scripts/get_pokemon.sh" "$CONKY_DIR/"
chmod +x "$CONKY_DIR/get_pokemon.sh"
cp "$SCRIPT_DIR/scripts/pokemon_refresh.sh" "$CONKY_DIR/"
chmod +x "$CONKY_DIR/pokemon_refresh.sh"
cp "$SCRIPT_DIR/scripts/pokemon_next.sh" "$CONKY_DIR/"
chmod +x "$CONKY_DIR/pokemon_next.sh"
cp "$SCRIPT_DIR/scripts/pokemon_click.lua" "$CONKY_DIR/"
mkdir -p "$CONKY_DIR/pokemon"
# Fetch initial Pokemon
"$CONKY_DIR/get_pokemon.sh"

# Music monitor script
cp "$SCRIPT_DIR/scripts/music_monitor.sh" "$CONKY_DIR/"
chmod +x "$CONKY_DIR/music_monitor.sh"

# Detect active network interface and update sysmon config
echo "[5/7] Detecting network interface..."
NET_IF=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'dev \K\S+' || echo "")
if [ -n "$NET_IF" ]; then
    sed -i "s/enp58s0/$NET_IF/g" "$CONKY_DIR/sysmon.conf"
    echo "    Using network interface: $NET_IF"
else
    echo "    Warning: No active network interface found, using default"
fi

# Setup autostart
echo "[6/7] Setting up autostart..."
mkdir -p "$AUTOSTART_DIR"
cat > "$AUTOSTART_DIR/conky.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Conky
Comment=Desktop Widgets
Exec=sh -c "sleep 5 && conky -d -c $CONKY_DIR/rock-roll.conf && conky -d -c $CONKY_DIR/quotes.conf && conky -d -c $CONKY_DIR/sysmon.conf && conky -d -c $CONKY_DIR/pokemon.conf && $CONKY_DIR/music_monitor.sh &"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=5
EOF

echo ""
echo "[7/7] Installation complete!"
echo ""
echo "Launching widgets now..."
killall conky 2>/dev/null || true
sleep 1
conky -d -c "$CONKY_DIR/rock-roll.conf"
conky -d -c "$CONKY_DIR/quotes.conf"
conky -d -c "$CONKY_DIR/sysmon.conf"
conky -d -c "$CONKY_DIR/pokemon.conf"
"$CONKY_DIR/music_monitor.sh" &
echo "All widgets are running!"
echo "Now Playing and Lyrics widgets will appear when music is playing."
echo ""
echo "Note: You may need to adjust xinerama_head in the configs"
echo "if your monitor setup differs from the original machine."
