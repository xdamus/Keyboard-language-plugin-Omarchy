# Keyboard Layout Switcher for Omarchy

A simple plugin to switch between keyboard layouts and add new languages.

## Features

- Click the layout indicator in the bar to open the dropdown
- Select any layout from the list of 40+ popular languages
- Current layout is highlighted with a checkmark
- Changes apply immediately

## Supported Layouts

English (US/UK), German, French, Spanish, Italian, Portuguese, Dutch, Belgian, Swiss, Swedish, Norwegian, Danish, Finnish, Russian, Ukrainian, Polish, Czech, Slovak, Hungarian, Romanian, Bulgarian, Croatian, Serbian, Slovenian, Lithuanian, Latvian, Estonian, Japanese, Korean, Chinese, Indian, Arabic, Hebrew, Turkish, Greek, Latin American, Canadian, Austrian, Irish, New Zealand, South African

## Installation

### Command-line install (recommended)

```bash
omarchy plugin add https://github.com/xdamus/Keyboard-language-plugin-Omarchy.git --enable
```

Then reload the shell:

```bash
omarchy-shell-reload
```

### One-line install script

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xdamus/Keyboard-language-plugin-Omarchy/main/install.sh)"
```

### Manual install

Copy this plugin to `~/.config/omarchy/plugins/damus.keyboard-switcher/`:

```bash
git clone https://github.com/xdamus/Keyboard-language-plugin-Omarchy.git ~/.config/omarchy/plugins/damus.keyboard-switcher
chmod +x ~/.config/omarchy/plugins/damus.keyboard-switcher/bin/*
omarchy-shell-reload
```

## Uninstall

```bash
omarchy plugin remove damus.keyboard-switcher
omarchy-shell-reload
```

## Adding Custom Layouts

To add a layout not in the list, edit `bin/list-layouts` and add an entry:

```json
{"code": "xx", "name": "Your Language", "current": false}
```

Replace `xx` with the XKB layout code (check `/usr/share/X11/xkb/symbols/`).

## License

MIT
