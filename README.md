# dotfiles

My Neovim setup, plus the tmux, Ghostty and bash bits that go with it.
Runs on Debian/Ubuntu and Apple Silicon macOS.

## Install

```sh
~/dotfiles/install.sh
```

The script is idempotent. Existing configs are moved to `*.bak-<timestamp>` before linking.

- **macOS**: Homebrew + `Brewfile`, and switches the login shell to Homebrew's bash.
- **Debian-based**: apt packages, plus the latest Neovim, tree-sitter CLI, Node.js LTS,
  lazygit and the JetBrainsMono Nerd Font installed under `~/.local`. Re-runs only download
  Neovim, tree-sitter, Node.js and lazygit when a newer release is out. Set the terminal font to
  *JetBrainsMono Nerd Font Mono* afterwards.

Both also get the Rust toolchain through rustup (`~/.cargo`) and uv for Python.

LSP servers, formatters and tree-sitter parsers install on first launch (`:Mason` to check).

## Layout

Stow packages, each mirroring `$HOME`:

```
nvim/      ~/.config/nvim
tmux/      ~/.tmux.conf
git/       ~/.config/git          (identity in ~/.config/git/local)
bash/      ~/.config/bash/rc.sh   (sourced from ~/.bashrc)
ghostty/   ~/.config/ghostty      (macOS only)
```

```
nvim/.config/nvim/
├── init.lua
└── lua/
    ├── config/    options, keymaps, autocmds, lazy bootstrap
    └── plugins/   one spec per file
```

The installer is split into parts that `install.sh` sources:

```
install/lib.sh      logging, latest release lookup
install/macos.sh    Homebrew, login shell
install/debian.sh   apt, Neovim, tree-sitter, Node.js, lazygit, font
install/link.sh     backs up what's in the way, then stows
install/tools.sh    Rust, uv, tmux and Neovim plugins
```

`tests/link.sh` runs the linking step against a throwaway `$HOME`.

## Tooling

| | LSP | Lint | Format |
|---|---|---|---|
| ![Python](https://img.shields.io/badge/Python-1E1E1E?logo=python&logoColor=3776AB) | pyright | ruff | ruff |
| ![Bash](https://img.shields.io/badge/Bash-1E1E1E?logo=gnubash&logoColor=4EAA25) | bashls | shellcheck | shfmt |
| ![Docker](https://img.shields.io/badge/Docker-1E1E1E?logo=docker&logoColor=2496ED) | dockerls, docker_compose_language_service, yamlls | hadolint | LSP |
| ![YAML](https://img.shields.io/badge/YAML-1E1E1E?logo=yaml&logoColor=CB171E) ![JSON](https://img.shields.io/badge/JSON-1E1E1E?logo=json&logoColor=FFFFFF) | yamlls / jsonls |  | LSP |
| ![SQL](https://img.shields.io/badge/SQL-1E1E1E?logo=postgresql&logoColor=4169E1) |  |  | sql-formatter (postgresql) |
| ![JavaScript](https://img.shields.io/badge/JavaScript-1E1E1E?logo=javascript&logoColor=F7DF1E) ![TypeScript](https://img.shields.io/badge/TypeScript-1E1E1E?logo=typescript&logoColor=3178C6) | tsc (TypeScript 7) | eslint | prettier |
| ![Rust](https://img.shields.io/badge/Rust-1E1E1E?logo=rust&logoColor=DEA584) | rust_analyzer | clippy | rustfmt |
| ![C](https://img.shields.io/badge/C-1E1E1E?logo=c&logoColor=659AD2) ![C++](https://img.shields.io/badge/C%2B%2B-1E1E1E?logo=cplusplus&logoColor=659AD2) ![CUDA](https://img.shields.io/badge/CUDA-1E1E1E?logo=nvidia&logoColor=76B900) | clangd |  | clang-format |
| ![Lua](https://img.shields.io/badge/Lua-1E1E1E?logo=lua&logoColor=5C5DC2) | lua_ls |  | stylua |

## Notes

- Images (snacks.nvim) are only enabled when running in Ghostty or kitty. Works inside tmux
  through `allow-passthrough`.
- CSV/TSV open in csvview with a sticky header; the buffer itself is untouched.
- Markdown is rendered in-buffer by render-markdown.nvim.
- CUDA files get clangd and clang-format, but compiling them and full completion need
  NVIDIA's CUDA toolkit, which the installer leaves to each machine.
