#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONKY_DIR="$HOME/.config/conky"
FONT_DIR="$HOME/.local/share/fonts"
AUTOSTART_DIR="$HOME/.config/autostart"

echo "=== Conky Desktop Widgets Installer ==="

# Install dependencies
echo "[1/6] Installing dependencies..."
sudo apt update -qq
sudo apt install -y conky-all playerctl jq curl

# Install fonts
echo "[2/6] Installing fonts..."
mkdir -p "$FONT_DIR"
cp "$SCRIPT_DIR/fonts/"* "$FONT_DIR/"
fc-cache -f "$FONT_DIR"

# Copy configs
echo "[3/6] Installing Conky configs..."
mkdir -p "$CONKY_DIR"
cp "$SCRIPT_DIR/configs/"* "$CONKY_DIR/"
cp "$SCRIPT_DIR/scripts/get_quote.sh" "$CONKY_DIR/"
chmod +x "$CONKY_DIR/get_quote.sh"
cp "$SCRIPT_DIR/scripts/get_lyrics.sh" "$CONKY_DIR/"
chmod +x "$CONKY_DIR/get_lyrics.sh"
cp "$SCRIPT_DIR/scripts/lyrics_scroll.lua" "$CONKY_DIR/"
mkdir -p "$CONKY_DIR/lyrics"

# Detect active network interface and update sysmon config
echo "[4/6] Detecting network interface..."
NET_IF=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'dev \K\S+' || echo "")
if [ -n "$NET_IF" ]; then
    sed -i "s/enp58s0/$NET_IF/g" "$CONKY_DIR/sysmon.conf"
    echo "    Using network interface: $NET_IF"
else
    echo "    Warning: No active network interface found, using default"
fi

# Setup autostart
echo "[5/6] Setting up autostart..."
mkdir -p "$AUTOSTART_DIR"
cat > "$AUTOSTART_DIR/conky.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Conky
Comment=Desktop Widgets
Exec=sh -c "sleep 5 && conky -d -c $CONKY_DIR/rock-roll.conf && conky -d -c $CONKY_DIR/quotes.conf && conky -d -c $CONKY_DIR/nowplaying.conf && conky -d -c $CONKY_DIR/sysmon.conf && conky -d -c $CONKY_DIR/lyrics.conf"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=5
EOF

echo ""
echo "[6/6] Installation complete!"
echo ""
echo "Launching widgets now..."
killall conky 2>/dev/null || true
sleep 1
conky -d -c "$CONKY_DIR/rock-roll.conf"
conky -d -c "$CONKY_DIR/quotes.conf"
conky -d -c "$CONKY_DIR/nowplaying.conf"
conky -d -c "$CONKY_DIR/sysmon.conf"
conky -d -c "$CONKY_DIR/lyrics.conf"
echo "All 5 widgets are running!"
echo ""
echo "Note: You may need to adjust xinerama_head in the configs"
echo "if your monitor setup differs from the original machine."
