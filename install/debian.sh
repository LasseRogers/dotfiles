# shellcheck shell=bash
# Sourced by install.sh.

install_debian() {
  command -v apt-get >/dev/null 2>&1 || die "only apt-based distributions are supported"

  local sudo=""
  [ "$(id -u)" -eq 0 ] || sudo="sudo"

  log "apt packages"
  $sudo apt-get update
  $sudo apt-get install -y \
    git curl unzip build-essential cmake \
    ripgrep fd-find fzf \
    nodejs npm python3-venv \
    xclip wl-clipboard \
    tmux bc gawk \
    stow fontconfig

  local nvim_arch ts_arch lg_arch
  case "$ARCH" in
    x86_64) nvim_arch=x86_64 ts_arch=x64 lg_arch=x86_64 ;;
    aarch64 | arm64) nvim_arch=arm64 ts_arch=arm64 lg_arch=arm64 ;;
    *) die "unsupported architecture: $ARCH" ;;
  esac

  # apt's neovim is too old for this config.
  log "Neovim (latest release)"
  rm -rf "$HOME/.local/opt/nvim"
  mkdir -p "$HOME/.local/opt/nvim"
  curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$nvim_arch.tar.gz" |
    tar xz -C "$HOME/.local/opt/nvim" --strip-components=1
  ln -sf "$HOME/.local/opt/nvim/bin/nvim" "$HOME/.local/bin/nvim"

  log "tree-sitter CLI"
  curl -fsSL "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-$ts_arch.gz" |
    gunzip >"$HOME/.local/bin/tree-sitter"
  chmod +x "$HOME/.local/bin/tree-sitter"

  if ! command -v lazygit >/dev/null 2>&1; then
    log "lazygit"
    local tag
    tag="$(latest_tag jesseduffield/lazygit)"
    if [ -z "$tag" ] || ! curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/$tag/lazygit_${tag#v}_Linux_$lg_arch.tar.gz" |
      tar xz -C "$HOME/.local/bin" lazygit; then
      warn "lazygit download failed, skipping"
    fi
  fi

  # Not grep -q: it exits on the first match, fc-list gets SIGPIPE, and pipefail fails the check.
  if ! fc-list : family | grep -i "JetBrainsMono Nerd Font Mono" >/dev/null; then
    log "JetBrainsMono Nerd Font"
    local tmp
    tmp="$(mktemp -d)"
    curl -fsSL -o "$tmp/font.zip" \
      https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    mkdir -p "$HOME/.local/share/fonts/JetBrainsMono"
    # Mono variant only. VTE-based terminals render the others with wide letter spacing.
    unzip -oq "$tmp/font.zip" 'JetBrainsMonoNerdFontMono-*' -d "$HOME/.local/share/fonts/JetBrainsMono"
    rm -rf "$tmp"
    fc-cache -f >/dev/null
  fi
}
