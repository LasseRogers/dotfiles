#!/usr/bin/env bash
#
# Runs link() against a throwaway $HOME.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=install/lib.sh
. "$REPO/install/lib.sh"
# shellcheck source=install/link.sh
. "$REPO/install/link.sh"

HOME="$(mktemp -d)"
trap 'rm -rf "$HOME"' EXIT
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

# Ghostty isn't stowed on Linux, so a config of the user's own must stay put.
mkdir -p "$HOME/.config/ghostty"
echo mine >"$HOME/.config/ghostty/config"
OS=Linux link >/dev/null
[ "$(cat "$HOME/.config/ghostty/config")" = mine ] || fail "ghostty config moved on Linux"
[ -L "$HOME/.tmux.conf" ] || fail "tmux.conf not linked"

echo "ok"
