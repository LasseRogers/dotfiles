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
backups() { compgen -G "$HOME/$1.bak-*" >/dev/null; }

# Ghostty isn't stowed on Linux, so a config of the user's own must stay put.
mkdir -p "$HOME/.config/ghostty"
echo mine >"$HOME/.config/ghostty/config"
# Old configs in the way: nvim is replaced whole, bash only file by file.
mkdir -p "$HOME/.config/nvim" "$HOME/.config/bash"
touch "$HOME/.config/nvim/init.vim" "$HOME/.config/bash/rc.sh" "$HOME/.tmux.conf"

OS=Linux link >/dev/null
[ "$(cat "$HOME/.config/ghostty/config")" = mine ] || fail "ghostty config moved on Linux"
[ -L "$HOME/.tmux.conf" ] || fail "tmux.conf not linked"
backups .tmux.conf || fail "tmux.conf not backed up"
[ -L "$HOME/.config/nvim" ] || fail "nvim dir not linked whole"
backups .config/nvim || fail "nvim dir not backed up"
[ ! -L "$HOME/.config/bash" ] || fail "bash dir linked instead of kept real"
[ -L "$HOME/.config/bash/rc.sh" ] || fail "rc.sh not linked"
backups .config/bash/rc.sh || fail "rc.sh not backed up"

[ ! -L "$HOME/.config/git" ] || fail "git dir linked instead of kept real"
[ -L "$HOME/.config/git/config" ] || fail "git config not linked"

# A second run finds everything ours and backs up nothing.
out="$(OS=Linux link)"
[[ "$out" != *backup:* ]] || fail "second run made backups"

echo "ok"
