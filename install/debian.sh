# shellcheck shell=bash
# Sourced by install.sh.

install_debian() {
  command -v apt-get >/dev/null 2>&1 || die "only apt-based distributions are supported"

  local sudo=""
  [ "$(id -u)" -eq 0 ] || sudo="sudo"

  # No imagemagick, unlike the Brewfile: snacks.nvim only shows images in Ghostty or kitty,
  # and these machines use GNOME Terminal.
  log "apt packages"
  $sudo apt-get update
  $sudo apt-get install -y \
    git curl unzip build-essential cmake \
    ripgrep fd-find fzf \
    python3-venv \
    xclip wl-clipboard \
    tmux bc gawk \
    stow fontconfig

  local nvim_arch ts_arch lg_arch node_arch
  # shellcheck disable=SC2153 # ARCH is set by install.sh
  case "$ARCH" in
    x86_64) nvim_arch=x86_64 ts_arch=x64 lg_arch=x86_64 node_arch=x64 ;;
    aarch64 | arm64) nvim_arch=arm64 ts_arch=arm64 lg_arch=arm64 node_arch=arm64 ;;
    *) die "unsupported architecture: $ARCH" ;;
  esac

  install_nvim "$nvim_arch"
  install_tree_sitter "$ts_arch"

  install_node "$node_arch"

  install_lazygit "$lg_arch"

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

  gnome_terminal_font
}

# apt's nodejs is too old for Mason's npm-based servers on most releases.
install_node() {
  local arch="$1" dir="$HOME/.local/opt/node" ver
  ver="$(curl -fsSL https://nodejs.org/dist/index.json |
    python3 -c 'import json, sys; print(next(r["version"] for r in json.load(sys.stdin) if r["lts"]))')"
  if [ "$("$dir/bin/node" --version 2>/dev/null)" != "$ver" ]; then
    log "Node.js $ver (LTS)"
    rm -rf "$dir"
    mkdir -p "$dir"
    curl -fsSL "https://nodejs.org/dist/$ver/node-$ver-linux-$arch.tar.gz" |
      tar xz -C "$dir" --strip-components=1
  fi
  ln -sf "$dir/bin/node" "$dir/bin/npm" "$dir/bin/npx" "$HOME/.local/bin/"
}

# `<bin> --version` as a release tag: "NVIM v0.11.5" and "tree-sitter 0.25.10 (...)" give v<x.y.z>.
installed_version() {
  "$1" --version 2>/dev/null | awk 'NR == 1 { v = $2; sub(/^v?/, "v", v); print v }'
}

# apt's neovim is too old for this config. Downloads only when the release tag changed;
# if the tag can't be looked up, falls back to always downloading.
install_nvim() {
  local arch="$1" dir="$HOME/.local/opt/nvim" tag
  tag="$(latest_tag neovim/neovim)"
  if [ -z "$tag" ] || [ "$(installed_version "$dir/bin/nvim")" != "$tag" ]; then
    log "Neovim ${tag:-(latest release)}"
    rm -rf "$dir"
    mkdir -p "$dir"
    curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$arch.tar.gz" |
      tar xz -C "$dir" --strip-components=1
  fi
  ln -sf "$dir/bin/nvim" "$HOME/.local/bin/nvim"
}

install_tree_sitter() {
  local arch="$1" bin="$HOME/.local/bin/tree-sitter" tag
  tag="$(latest_tag tree-sitter/tree-sitter)"
  if [ -z "$tag" ] || [ "$(installed_version "$bin")" != "$tag" ]; then
    log "tree-sitter CLI ${tag:-(latest release)}"
    curl -fsSL "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-$arch.gz" |
      gunzip >"$bin"
    chmod +x "$bin"
  fi
}

# Asset names carry the version, so without a tag there is nothing to download.
install_lazygit() {
  local arch="$1" bin="$HOME/.local/bin/lazygit" tag
  tag="$(latest_tag jesseduffield/lazygit)"
  if [ -z "$tag" ]; then
    warn "couldn't look up the latest lazygit release, skipping"
    return 0
  fi
  # `lazygit --version` is "commit=..., version=0.56.0, ..., git version=..."
  [ "$("$bin" --version 2>/dev/null | sed -n 's/.*, version=\([^,]*\),.*/v\1/p')" = "$tag" ] && return 0
  log "lazygit $tag"
  curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/$tag/lazygit_${tag#v}_Linux_$arch.tar.gz" |
    tar xz -C "$HOME/.local/bin" lazygit ||
    warn "lazygit download failed, skipping"
}

# Points GNOME Terminal's default profile at the Nerd Font. Skipped when it already uses it,
# so a size picked by hand survives re-runs, and without GNOME Terminal or a desktop session.
gnome_terminal_font() {
  command -v gsettings >/dev/null 2>&1 || return 0
  # Not grep -q, for the same SIGPIPE reason as the fc-list check.
  gsettings list-schemas 2>/dev/null | grep -x org.gnome.Terminal.ProfilesList >/dev/null || return 0
  local profile path
  profile="$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")"
  path="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/"
  if [ "$(gsettings get "$path" use-system-font)" = false ] &&
    [[ "$(gsettings get "$path" font)" == *"JetBrainsMono Nerd Font Mono"* ]]; then
    return 0
  fi
  log "GNOME Terminal font"
  if ! gsettings set "$path" use-system-font false ||
    ! gsettings set "$path" font 'JetBrainsMono Nerd Font Mono 12'; then
    warn "couldn't set the GNOME Terminal font"
  fi
}
