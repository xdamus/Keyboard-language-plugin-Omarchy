# Keyboard Layout Switcher for Omarchy

A simple, reliable plugin to switch between keyboard layouts right from your Omarchy bar.

## Features

- Click the **layout indicator** (e.g. "EN") in the bar to open the dropdown
- Select from **39 popular keyboard layouts** plus any custom ones you add
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

English (US/UK), German, French, Spanish, Italian, Portuguese, Portuguese (Brazil), Dutch, Belgian, Swiss, Swedish, Norwegian, Danish, Finnish, Russian, Ukrainian, Polish, Czech, Slovak, Hungarian, Romanian, Bulgarian, Croatian, Serbian, Slovenian, Lithuanian, Latvian, Estonian, Turkish, Greek, Arabic, Persian, Japanese, Korean, Chinese, Indian, Thai, Vietnamese — and **Hebrew**, available to add but **not active by default**.

Any other layout can be added with the **+** button using its XKB code (found in `/usr/share/X11/xkb/symbols/`).

## Requirements

- [Omarchy](https://github.com/omarchy/omarchy) on **Hyprland** (Wayland)
- `hyprctl` (part of Hyprland) and `python3` for the layout helpers

Switching is native to Hyprland via `hyprctl switchxkblayout`; it does **not** use
`setxkbmap` (which only affects XWayland apps and cannot switch real typing on Hyprland).

> **How active layouts work:** Hyprland types using the layouts listed in
> `input:kb_layout`. This plugin keeps a comma-separated active list in
> `~/.config/omarchy/keyboard-layouts-active` (read by your Hyprland config) and
> switches between them. fcitx5/Hyprland on this system cycles layouts reliably up to
> **4 active layouts**; adding more evicts a non-current one to stay within the cap.

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

## Files the plugin uses

This plugin only reads/writes its **own** files — it never edits your shell,
Hyprland, or other user configuration:

- `~/.config/omarchy/keyboard-layouts-active` — the active layout list (e.g. `us,de,fr`)
- `~/.config/omarchy/keyboard-layouts.conf.json` — your custom layouts
- The plugin folder itself (`~/.config/omarchy/plugins/damus.keyboard-switcher/`)

Your Hyprland config must reference the active-list file so typing follows the
switcher (the plugin ships a drop-in `~/.config/hypr/input.lua` block for this).

## Uninstall

```bash
omarchy plugin remove damus.keyboard-switcher
omarchy-restart-shell
```

## License

MIT — see the [LICENSE](LICENSE) file. Copyright (c) 2026 damus.
