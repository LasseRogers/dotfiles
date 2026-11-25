# shellcheck shell=bash
# Sourced from ~/.bashrc.

[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export EDITOR=nvim
export VISUAL=nvim

alias vim=nvim
alias lg=lazygit

# Debian ships fd as fdfind.
command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1 && alias fd=fdfind

if command -v fzf >/dev/null 2>&1; then
  if fzf --bash >/dev/null 2>&1; then
    eval "$(fzf --bash)"
  elif [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
    # fzf < 0.48 (Debian/Ubuntu apt) has no --bash flag.
    # shellcheck source=/dev/null
    . /usr/share/doc/fzf/examples/key-bindings.bash
  fi
fi

# Large shared history. Runs after Debian's default .bashrc, so these sizes win.
HISTSIZE=100000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
# Write each command as it runs, so closing one of several panes doesn't drop the others'.
[[ "$PROMPT_COMMAND" == *"history -a"* ]] || PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# Prompt: folder, then the git branch (or short commit when detached).
__git_branch() {
  local b
  b="$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)" && printf ' (%s)' "$b"
}
PS1='\[\e[1;34m\]\w\[\e[0;35m\]$(__git_branch)\[\e[0m\] \$ '

# Debian's default .bashrc already loads completion; Homebrew's bash doesn't.
if [ -n "${HOMEBREW_PREFIX:-}" ] && [ -r "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" ]; then
  # shellcheck source=/dev/null
  . "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
fi
