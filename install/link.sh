# shellcheck shell=bash
# Sourced by install.sh.

link() {
  log "Linking configs"
  local packages=(nvim tmux bash)
  # Paths the packages own in $HOME; only these are cleared before stowing.
  local files=(.config/nvim .tmux.conf .config/bash/rc.sh)
  if [ "$OS" = Darwin ]; then
    packages+=(ghostty)
    files+=(.config/ghostty/config)
    mkdir -p "$HOME/.config/ghostty"
  fi

  # Anything in the way that isn't already ours gets moved aside; dangling links are removed.
  local stamp f target
  stamp="$(date +%Y%m%d-%H%M%S)"
  for f in "${files[@]}"; do
    target="$HOME/$f"
    if [ -L "$target" ] && [[ "$(readlink -f "$target" 2>/dev/null)" == "$REPO"/* ]]; then
      continue
    elif [ -L "$target" ] && [ ! -e "$target" ]; then
      rm "$target"
    elif [ -e "$target" ] || [ -L "$target" ]; then
      echo "backup: ~/$f -> ~/$f.bak-$stamp"
      mv "$target" "$target.bak-$stamp"
    fi
  done

  mkdir -p "$HOME/.config/bash"
  stow -d "$REPO" -t "$HOME" --restow "${packages[@]}"

  touch "$HOME/.bashrc"
  grep -q '.config/bash/rc.sh' "$HOME/.bashrc" ||
    echo '[ -f ~/.config/bash/rc.sh ] && . ~/.config/bash/rc.sh' >>"$HOME/.bashrc"
}
