#!/usr/bin/env bash
#
# Bootstrap for Debian/Ubuntu and Apple Silicon macOS. Idempotent.
# Parts are sourced, not executed, so PATH and brew shellenv carry across them.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"
ARCH="$(uname -m)"

mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

# shellcheck source=install/lib.sh
. "$REPO/install/lib.sh"
# shellcheck source=install/macos.sh
. "$REPO/install/macos.sh"
# shellcheck source=install/debian.sh
. "$REPO/install/debian.sh"
# shellcheck source=install/link.sh
. "$REPO/install/link.sh"
# shellcheck source=install/tools.sh
. "$REPO/install/tools.sh"

case "$OS" in
  Darwin) install_macos ;;
  Linux) install_debian ;;
  *) die "unsupported OS: $OS" ;;
esac

link
rust_toolchain
uv_install
tmux_plugins
nvim_plugins

log "Done"
echo "Open a new shell and run nvim. LSP servers and parsers install on first launch."
[ "$OS" = Linux ] && echo "Set your terminal font to JetBrainsMono Nerd Font Mono."
exit 0
