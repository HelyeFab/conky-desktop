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

## Quick Install

```bash
git clone https://github.com/HelyeFab/conky-desktop.git
cd conky-desktop
./install.sh
```

The install script will:
- Install `conky-all` and `playerctl`
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

## Dependencies

- `conky-all`
- `playerctl`
- Fonts: Anurati, Chilanka, Roboto Mono (included in `fonts/`)

## Tested On

- Debian Trixie (GNOME / Wayland)

## License

GPLv3
