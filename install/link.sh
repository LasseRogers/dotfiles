# shellcheck shell=bash
# Sourced by install.sh.

in_list() {
  local x="$1" e
  shift
  for e; do [ "$e" = "$x" ] && return 0; done
  return 1
}

# Prints what a package links into $HOME: each path directly under its root or a shared dir.
owned() {
  local root="$1" p parent
  shift
  (cd "$root" && find . -mindepth 1 | sed 's|^\./||') | while IFS= read -r p; do
    in_list "$p" "$@" && continue
    parent="$(dirname "$p")"
    if [ "$parent" = . ] || in_list "$parent" "$@"; then echo "$p"; fi
  done
}

link() {
  log "Linking configs"
  local packages=(nvim tmux bash git)
  [ "$OS" = Darwin ] && packages+=(ghostty)
  # Kept as real dirs so other files can live beside ours; anything else is linked whole.
  local shared=(.config .config/bash .config/ghostty .config/git)

  # Anything in the way that isn't already ours gets moved aside; dangling links are removed.
  local stamp pkg d f target
  stamp="$(date +%Y%m%d-%H%M%S)"
  for pkg in "${packages[@]}"; do
    for d in "${shared[@]}"; do
      if [ -d "$REPO/$pkg/$d" ]; then mkdir -p "$HOME/$d"; fi
    done
    while IFS= read -r f; do
      target="$HOME/$f"
      if [ -L "$target" ] && [[ "$(readlink -f "$target" 2>/dev/null)" == "$REPO"/* ]]; then
        continue
      elif [ -L "$target" ] && [ ! -e "$target" ]; then
        rm "$target"
      elif [ -e "$target" ] || [ -L "$target" ]; then
        echo "backup: ~/$f -> ~/$f.bak-$stamp"
        mv "$target" "$target.bak-$stamp"
      fi
    done < <(owned "$REPO/$pkg" "${shared[@]}")
  done

  stow -d "$REPO" -t "$HOME" --restow "${packages[@]}"

  touch "$HOME/.bashrc"
  grep -q '.config/bash/rc.sh' "$HOME/.bashrc" ||
    echo '[ -f ~/.config/bash/rc.sh ] && . ~/.config/bash/rc.sh' >>"$HOME/.bashrc"
}
