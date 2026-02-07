#!/bin/bash

echo "=== Conky Desktop Widgets Uninstaller ==="

killall conky 2>/dev/null || true

rm -f "$HOME/.config/conky/rock-roll.conf"
rm -f "$HOME/.config/conky/quotes.conf"
rm -f "$HOME/.config/conky/nowplaying.conf"
rm -f "$HOME/.config/conky/sysmon.conf"
rm -f "$HOME/.config/conky/get_quote.sh"
rm -f "$HOME/.config/conky/quote_cache.txt"
rm -f "$HOME/.config/autostart/conky.desktop"

echo "Done! Widgets removed."
