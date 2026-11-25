# shellcheck shell=bash
# Sourced by install.sh.

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }
die() {
  printf '\033[1;31merror:\033[0m %s\n' "$*" >&2
  exit 1
}

# Tries the API first, then the /releases/latest redirect (no rate limit).
latest_tag() {
  local tag
  tag="$(curl -fsSL "https://api.github.com/repos/$1/releases/latest" 2>/dev/null |
    grep -m1 '"tag_name"' | cut -d'"' -f4)" || true
  if [ -z "$tag" ]; then
    tag="$(curl -fsSL -o /dev/null -w '%{url_effective}' "https://github.com/$1/releases/latest" 2>/dev/null |
      sed -n 's|.*/tag/||p')" || true
  fi
  echo "$tag"
}
