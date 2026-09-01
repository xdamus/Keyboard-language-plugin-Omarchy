#!/bin/bash
# Keyboard Layout Switcher - Hyprland layout manager.
#
# Hyprland/Wayland does not type by setxkbmap; it types by the layouts listed
# in `input:kb_layout` and switches between them with `hyprctl switchxkblayout`.
# This manager keeps a persistent comma-separated active-layout list (the
# plugin reads it from input.lua) and switches real typing via hyprctl.
#
# Usage:
#   layouts-manager get                  - print the current layout code (e.g. "il")
#   layouts-manager active               - print the active-layout code string
#   layouts-manager set "us,il,de"       - set the active layout list (reconfigure)
#   layouts-manager switch CODE          - make CODE active and switch typing to it
#   layouts-manager list                 - print active layouts as JSON

set -euo pipefail

# Max number of simultaneously active layouts. fcitx5/Hyprland on this system
# only cycles layouts reliably up to this count; exceeding it makes
# switchxkblayout report the index out of range.
MAX_ACTIVE=4

# Directory holding this script (the plugin's bin/ directory).
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_FILE="$HOME/.config/omarchy/keyboard-layouts-active"
XKB_SYMBOLS="/usr/share/X11/xkb/symbols"

# Keyboards Hyprland lists that nobody types on.
NON_TYPED="video-bus|power-button|sleep-button|thinkpad-extra-buttons|hl-virtual-keyboard"

die() { echo "Error: $*" >&2; exit 1; }

command -v hyprctl >/dev/null 2>&1 || die "hyprctl not found"

read_active() {
  if [ -f "$CONFIG_FILE" ]; then
    tr -d '[:space:]' < "$CONFIG_FILE"
  else
    echo ""
  fi
}

type_keyboard() {
  hyprctl -j devices 2>/dev/null | python3 -c "
import json, sys
s = sys.stdin.read()
try:
    data = json.loads(s)
except Exception:
    sys.exit(0)
non = '$NON_TYPED'
for kb in (data.get('keyboards') or []):
    name = kb.get('name') or ''
    if non and __import__('re').search(non, name):
        continue
    if not name:
        continue
    print(name)
    sys.exit(0)
" || true
}

layout_codes() {
  # The active list in config order. Guarantee a trailing newline so
  # `while read` still processes the final (possibly newline-less) entry.
  read_active | tr ',' '\n'
  echo
}

find_index() {
  # index of CODE in the active list (0-based), or empty if not present
  local code="$1" i=0 c
  while IFS= read -r c; do
    [ -z "$c" ] && continue
    if [ "$c" = "$code" ]; then
      echo "$i"
      return 0
    fi
    i=$((i+1))
  done < <(layout_codes)
  return 1
}

set_active_list() {
  local list
  list="$(echo "$1" | tr -d '[:space:]' | sed 's/^,*//; s/,*$//')"
  [ -n "$list" ] || die "empty layout list"
  # Validate each code exists in xkb symbols
  local code
  IFS=',' read -ra codes <<< "$list"
  for code in "${codes[@]}"; do
    if ! [[ "$code" =~ ^[a-zA-Z0-9_-]+$ ]]; then
      die "invalid layout code '$code'"
    fi
    if [ ! -f "$XKB_SYMBOLS/$code" ]; then
      die "layout '$code' not found in $XKB_SYMBOLS/"
    fi
  done
  mkdir -p "$(dirname "$CONFIG_FILE")"
  printf '%s\n' "$list" > "$CONFIG_FILE"
  hyprctl reload >/dev/null 2>&1 || true
  sleep 0.3
  echo "$list"
}

get_current() {
  # Print the active keymap display name ("English (US)", "Hebrew", "German").
  # The caller maps this back to a layout code / name from its own table.
  local kb
  kb="$(type_keyboard)"
  [ -n "$kb" ] || return 1
  hyprctl -j devices 2>/dev/null | python3 -c "
import json, sys
data = json.loads(sys.stdin.read())
kb = '$kb'
for k in (data.get('keyboards') or []):
    if k.get('name') == kb:
        print(k.get('active_keymap') or '')
        sys.exit(0)
"
}

switch_layout() {
  # Hyprland (with fcitx5) only cycles a small number of layouts reliably; this
  # system is capped at 4. Keep the active list <= MAX (4): if the requested
  # layout is already active, switch straight to it; otherwise add it, evicting
  # a non-current layout if the list is full, then switch to it.
  local code cur list idx kb new_list
  code="$1"
  if ! [[ "$code" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    die "invalid layout code '$code'"
  fi
  if [ ! -f "$XKB_SYMBOLS/$code" ]; then
    die "layout '$code' not found in $XKB_SYMBOLS/"
  fi

  list="$(read_active)"
  cur="$(current_code)"

  if idx="$(find_index "$code")"; then
    kb="$(type_keyboard)"
    [ -n "$kb" ] || die "no typed keyboard found"
    hyprctl switchxkblayout "$kb" "$idx" >/dev/null 2>&1 || die "switchxkblayout failed"
    echo "Switched to: $code"
    return 0
  fi

  # Build the new active list, capped at MAX_ACTIVE layouts.
  new_list="$(build_new_list "$list" "$code" "$cur")"
  set_active_list "$new_list" >/dev/null
  kb="$(type_keyboard)"
  [ -n "$kb" ] || die "no typed keyboard found"
  idx="$(find_index "$code")" || die "layout '$code' not active"
  hyprctl switchxkblayout "$kb" "$idx" >/dev/null 2>&1 || die "switchxkblayout failed"
  echo "Switched to: $code"
}

current_code() {
  # Return the code currently active, by matching active_keymap to each active
  # layout code's display name via the layout list.
  local active
  active="$(get_current)"
  [ -n "$active" ] || return 0
  # Map display name -> code from the plugin's known list of layouts.
  "$PLUGIN_DIR/bin/layout-names.sh" findcode "$active" 2>/dev/null || true
}

build_new_list() {
  local list="$1" new="$2" cur="$3"
  local IFS=',' codes=() out=() c keep_cur
  IFS=',' read -r -a codes <<< "$list"
  keep_cur=""
  for c in "${codes[@]}"; do
    [ -z "$c" ] && continue
    if [ "$c" = "$cur" ]; then keep_cur="$c"; fi
  done
  # Keep current first, then the rest (excluding the new code), up to MAX-1.
  if [ -n "$keep_cur" ]; then out+=("$keep_cur"); fi
  for c in "${codes[@]}"; do
    [ -z "$c" ] && continue
    [ "$c" = "$cur" ] || [ "$c" = "$new" ] && continue
    if [ "${#out[@]}" -lt "$((MAX_ACTIVE-1))" ]; then out+=("$c"); fi
  done
  # Add the new code to reach MAX.
  if [ "${#out[@]}" -le "$((MAX_ACTIVE-1))" ]; then out+=("$new"); fi
  local result=""
  for c in "${out[@]}"; do
    [ -z "$c" ] && continue
    result="${result:+$result,}$c"
  done
  echo "$result"
}

list_active() {
  read_active | awk -F, '{
    n=split($0,a,",")
    printf "["
    for(i=1;i<=n;i++){ if(a[i]!=""){ printf "%s{\"code\":\"%s\"}", (i>1?",":""), a[i] } }
    printf "]"
  }'
}

case "${1:-}" in
  get)
    get_current
    ;;
  active)
    read_active
    ;;
  set)
    [ -n "${2:-}" ] || die "usage: layouts-manager set \"us,il,de\""
    set_active_list "$2"
    ;;
  switch)
    [ -n "${2:-}" ] || die "usage: layouts-manager switch CODE"
    switch_layout "$2"
    ;;
  list)
    list_active
    ;;
  *)
    echo "Usage: $(basename "$0") {get|active|set \"list\"|switch CODE|list}" >&2
    exit 1
    ;;
esac
