# Conky Desktop Widgets

A portable, minimal set of Conky widgets for Linux desktops. Transparent, clean, and designed to complement any wallpaper.

![Desktop Preview](screenshots/desktop.png)

## Widgets

| Widget | Position | Description |
|--------|----------|-------------|
| **Rock & Roll Clock** | Center | Day of the week in futuristic Anurati font, date, and time |
| **Inspirational Quotes** | Top-left | Random quotes fetched from ZenQuotes API, refreshes every 5 min |
| **System Monitor** | Top-right | CPU, RAM, disk usage, and network speed |
| **Now Playing** | Bottom-left | Currently playing song via playerctl (Spotify, VLC, etc.) |
| **Lyrics** | Bottom-right | Auto-scrolling lyrics for the current song, fetched from lrclib.net/lyrics.ovh |

## Quick Install

```bash
git clone https://github.com/HelyeFab/conky-desktop.git
cd conky-desktop
./install.sh
```

The install script will:
- Install `conky-all`, `playerctl`, `jq`, and `curl`
- Install custom fonts (Anurati, Chilanka, Roboto Mono)
- Copy widget configs to `~/.config/conky/`
- Auto-detect your active network interface
- Set up autostart on login

## Uninstall

```bash
./uninstall.sh
```

## Manual Launch

```bash
conky -d -c ~/.config/conky/rock-roll.conf
conky -d -c ~/.config/conky/quotes.conf
conky -d -c ~/.config/conky/sysmon.conf
conky -d -c ~/.config/conky/nowplaying.conf
conky -d -c ~/.config/conky/lyrics.conf
```

To stop all widgets:

```bash
killall conky
```

## Configuration

All config files are in `~/.config/conky/`. Common tweaks:

- **Position:** Change `alignment` (e.g. `top_left`, `bottom_right`, `middle_middle`)
- **Monitor:** Change `xinerama_head` (0 or 1) to target a different display
- **Quote refresh rate:** Change the `execpi` interval in `quotes.conf` (default 300 seconds)
- **Network interface:** Update the interface name in `sysmon.conf` if needed
- **Lyrics scroll speed:** Change the `execpi` interval in `lyrics.conf` (default 10 seconds)
- **Lyrics visible lines:** Change `LINES_TO_SHOW` in `get_lyrics.sh` (default 16)
- **Lyrics scroll step:** Change `SCROLL_STEP` in `get_lyrics.sh` (default 3 lines per cycle)

## Dependencies

- `conky-all`
- `playerctl`
- `jq`
- `curl`
- Fonts: Anurati, Chilanka, Roboto Mono (included in `fonts/`)

## Tested On

- Debian Trixie (GNOME / Wayland)

## License

GPLv3
