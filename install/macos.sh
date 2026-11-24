# shellcheck shell=bash
# Sourced by install.sh.

install_macos() {
  [ "$ARCH" = arm64 ] || die "only Apple Silicon is supported"

  if ! command -v brew >/dev/null 2>&1; then
    log "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"

  log "brew bundle"
  brew bundle --file "$REPO/Brewfile"

  # /bin/bash on macOS is 3.2.
  local brew_bash
  brew_bash="$(brew --prefix)/bin/bash"
  if ! grep -qx "$brew_bash" /etc/shells; then
    log "Adding $brew_bash to /etc/shells"
    echo "$brew_bash" | sudo tee -a /etc/shells >/dev/null
  fi
  if [ "$SHELL" != "$brew_bash" ]; then
    log "Setting login shell to $brew_bash"
    chsh -s "$brew_bash"
  fi

  # Terminal apps on macOS start login shells, which only read ~/.bash_profile.
  touch "$HOME/.bash_profile"
  grep -q '.bashrc' "$HOME/.bash_profile" ||
    echo '[ -f ~/.bashrc ] && . ~/.bashrc' >>"$HOME/.bash_profile"
}
