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
  Neovim, tree-sitter and Node.js when a newer release is out. Set the terminal font to
  *JetBrainsMono Nerd Font Mono* afterwards.

Both also get the Rust toolchain through rustup (`~/.cargo`) and uv for Python.

LSP servers, formatters and tree-sitter parsers install on first launch (`:Mason` to check).

## Layout

Stow packages, each mirroring `$HOME`:

```
nvim/      ~/.config/nvim
tmux/      ~/.tmux.conf
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

## Keys

Leader is `<Space>`.

| Key | |
|---|---|
| `<C-p>` | find files |
| `<leader>fg` | live grep |
| `<leader>fb` `<leader>fr` | buffers, recent files |
| `<C-n>` | file tree |
| `K` | hover |
| `<leader>gd` `<leader>gr` | definition, references |
| `<leader>rn` | rename |
| `<leader>ca` | code action |
| `<leader>gf` | format |
| `<leader>d` | line diagnostics |
| `<leader>x` | close buffer, keep the window (hides a terminal instead) |
| `<leader>t` | terminal: open/focus, hide when focused; restarts if the shell exited |
| `<leader>R` | save and run current file with bash |
| `<leader>gp` `<leader>gt` | preview hunk, toggle blame |
| `<leader>gv` | toggle side-by-side diff against HEAD |
| `<leader>lg` | lazygit |
| `<leader>mr` | toggle markdown rendering |
| `<leader>cv` | toggle CSV view |
| `<C-h/j/k/l>` | move between splits and tmux panes (also from terminal mode) |
| `<Esc><Esc>` | leave terminal mode; then `q` or `<leader>t` hides the terminal |

Completion: `<Tab>` accepts, `<CR>` is always a newline.

tmux prefix is `<C-s>`. `|` and `-` split, `r` reloads, `I` installs plugins.

## Languages

| | LSP | Lint | Format |
|---|---|---|---|
| Python | pyright, ruff | ruff | ruff |
| Bash | bashls | shellcheck | shfmt |
| Dockerfile | dockerls | hadolint | LSP |
| Compose | docker_compose_language_service, yamlls | | LSP |
| YAML / JSON | yamlls / jsonls | | LSP |
| SQL | | | sql-formatter (postgresql) |
| JavaScript / TypeScript | tsc (TypeScript 7) | eslint | prettier |
| Rust | rust_analyzer | clippy | rustfmt |
| C / C++ / CUDA | clangd | | clang-format |
| Lua | lua_ls | | stylua |

## Notes

- Images (snacks.nvim) are only enabled when running in Ghostty or kitty. Works inside tmux
  through `allow-passthrough`.
- CSV/TSV open in csvview with a sticky header; the buffer itself is untouched.
- Markdown is rendered in-buffer by render-markdown.nvim.
