#!/bin/bash
# Map keyboard layout codes <-> Hyprland display names.
#
# Usage:
#   layout-names findcode "DISPLAY NAME"  -> prints the matching code ("es" etc.)
#   layout-names plainname CODE           -> prints a short code-derived initials ("ES")
#
# Hyprland reports the active layout as a display name ("Spanish", "English (US)")
# via hyprctl devices. We map that back to the XKB code we manage. Names come
# from xkbCommonName() in xkbcommon; a handful are verified against this system.

set -euo pipefail

# code|Hyprland display name (lowercased for matching)
MAP="
us|english (us)
gb|english (uk)
de|german
fr|french
es|spanish
it|italian
pt|portuguese
br|portuguese (brazil)
nl|dutch
be|belgian
ch|swiss
se|swedish
no|norwegian
dk|danish
fi|finnish
ru|russian
ua|ukrainian
pl|polish
cs|czech
sk|slovak
hu|hungarian
ro|romanian
bg|bulgarian
hr|croatian
sr|serbian
sl|slovenian
lt|lithuanian
lv|latvian
et|estonian
tr|turkish
el|greek
he|hebrew
ar|arabic
fa|persian
ja|japanese
ko|korean
zh|chinese
hi|indian
th|thai
vi|vietnamese
"

case "${1:-}" in
  findcode)
    want="$(printf '%s' "${2:-}" | tr '[:upper:]' '[:lower:]')"
    [ -n "$want" ] || exit 1
    while IFS='|' read -r code name; do
      [ -n "$code" ] || continue
      if [ "$name" = "$want" ]; then
        printf '%s\n' "$code"
        exit 0
      fi
    done <<< "$MAP"
    exit 1
    ;;
  plainname)
    # Echo the first two letters of the code uppercased as a stable label.
    printf '%s\n' "${2:-}" | tr -d '[:space:]' | cut -c1-2 | tr '[:lower:]' '[:upper:]'
    ;;
  *)
    echo "Usage: $(basename "$0") {findcode NAME|plainname CODE}" >&2
    exit 1
    ;;
esac
