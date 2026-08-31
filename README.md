# Keyboard Layout Switcher for Omarchy

A simple, reliable plugin to switch between keyboard layouts right from your Omarchy bar.

## Features

- Click the **layout indicator** (e.g. "EN") in the bar to open the dropdown
- Select from **40+ popular keyboard layouts**
- **"+" button** to add a new/custom keyboard language inline (with a friendly name)
- Remove a custom layout with the **✕** button
- Current layout is highlighted with a checkmark
- Changes apply immediately
- Your custom layouts are persisted across restarts

## How it looks

- The bar button shows the **first two letters** of the current language (e.g. "EN" for English)
- Click to open the layout picker
- Click a layout to switch, click **✕** next to a custom layout to remove it, or use **+ Add language** to add a new one

## Supported Built-in Layouts

English (US/UK), German, French, Spanish, Italian, Portuguese, Dutch, Belgian, Swiss, Swedish, Norwegian, Danish, Finnish, Russian, Ukrainian, Polish, Czech, Slovak, Hungarian, Romanian, Bulgarian, Croatian, Serbian, Slovenian, Lithuanian, Latvian, Estonian, Japanese, Korean, Chinese, Indian, Arabic, Hebrew, Turkish, Greek, Latin American, Canadian, Austrian, Irish, New Zealand, South African

Any other layout can be added with the **+** button using its XKB code (found in `/usr/share/X11/xkb/symbols/`).

## Requirements

- [Omarchy](https://github.com/omarchy/omarchy) on an X11/XWayland keyboard-managed session
- `setxkbmap` installed

## Installation

### Command-line install (recommended)

```bash
omarchy plugin add https://github.com/xdamus/Keyboard-language-plugin-Omarchy.git --enable
```

Then reload the shell:

```bash
omarchy-restart-shell
```

### One-line install script

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xdamus/Keyboard-language-plugin-Omarchy/master/install.sh)"
```

### Manual install

Copy this plugin to `~/.config/omarchy/plugins/damus.keyboard-switcher/`:

```bash
git clone https://github.com/xdamus/Keyboard-language-plugin-Omarchy.git ~/.config/omarchy/plugins/damus.keyboard-switcher
chmod +x ~/.config/omarchy/plugins/damus.keyboard-switcher/bin/*
omarchy-restart-shell
```

## Custom Layouts

Custom layouts are stored in `~/.config/omarchy/keyboard-layouts.conf.json` and can also be managed directly from the terminal:

```bash
# list custom layouts
~/.config/omarchy/plugins/damus.keyboard-switcher/bin/custom-layouts list

# add one
~/.config/omarchy/plugins/damus.keyboard-switcher/bin/custom-layouts add de "German"

# remove one
~/.config/omarchy/plugins/damus.keyboard-switcher/bin/custom-layouts remove de
```

## Uninstall

```bash
omarchy plugin remove damus.keyboard-switcher
omarchy-restart-shell
```

## License

MIT
