# shellcheck shell=bash
# Sourced by install.sh.

# rustup, not apt/brew: toolchain updates and components (rust-src for rust-analyzer).
rust_toolchain() {
  if ! command -v rustup >/dev/null 2>&1 && [ ! -x "$HOME/.cargo/bin/rustup" ]; then
    log "Rust (rustup)"
    local script
    if ! script="$(curl -fsSL https://sh.rustup.rs)" ||
      ! sh -c "$script" -- -y --no-modify-path --profile default; then
      warn "rustup install failed, skipping Rust"
      return 0
    fi
  fi

  # An existing rustup (older install, minimal profile, apt) can lack these; the files in
  # ~/.cargo/bin are proxies that exist either way, so install the components explicitly.
  local rustup
  rustup="$(command -v rustup || echo "$HOME/.cargo/bin/rustup")"
  "$rustup" default >/dev/null 2>&1 || "$rustup" default stable >/dev/null ||
    {
      warn "couldn't set a default Rust toolchain"
      return 0
    }
  "$rustup" component add rust-src rustfmt clippy >/dev/null ||
    warn "couldn't add rust-src/rustfmt/clippy"
}

# Installs to ~/.local/bin, already on PATH via rc.sh, so the installer must not edit shell files.
uv_install() {
  command -v uv >/dev/null 2>&1 && return 0
  log "uv"
  local script
  if ! script="$(curl -LsSf https://astral.sh/uv/install.sh)" ||
    ! UV_NO_MODIFY_PATH=1 sh -c "$script"; then
    warn "uv install failed, skipping"
  fi
}

tmux_plugins() {
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone -q --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  fi
  log "tmux plugins"
  "$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null || true
}

nvim_plugins() {
  log "Neovim plugins"
  nvim --headless "+Lazy! sync" +qa
}
