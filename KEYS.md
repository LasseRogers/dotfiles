# Keys

Leader is `<Space>`. All mappings are normal mode unless noted.

## Find

| Key | |
|---|---|
| `<C-p>` | find a file by name |
| `<leader>fg` | search file contents across the project (live grep) |
| `<leader>fb` | switch between open buffers; `<M-d>` closes the selected one (`<Tab>` to mark several) |
| `<leader>fr` | reopen a recent file |
| `<C-n>` | toggle the file tree, revealing the current file |

## Code

| Key | |
|---|---|
| `K` | show docs and type info for the symbol under the cursor |
| `<leader>gd` | jump to the definition of the symbol under the cursor (`<C-o>` jumps back) |
| `<leader>gr` | list every reference to the symbol under the cursor |
| `<leader>rn` | rename the symbol under the cursor across the project |
| `<leader>ca` | show code actions: quick fixes, imports, refactors |
| `<leader>gf` | format the buffer, or the selection in visual mode |
| `<leader>d` | show the full diagnostic for the current line |

Completion (insert mode): `<Tab>` accepts the suggestion, `<CR>` always inserts a newline.

## Buffers and windows

| Key | |
|---|---|
| `<leader>w` | save the buffer |
| `<leader>q` | close the window; quits nvim if it's the last one |
| `<leader>x` | close the buffer but keep the window; hides a terminal instead of killing it |
| `<C-h/j/k/l>` | move to the split or tmux pane left/down/up/right; also works from terminal mode |

## Terminal

| Key | |
|---|---|
| `<leader>t` | toggle the terminal: open and focus it, hide it when focused; restarts it if the shell exited |
| `<Esc><Esc>` | leave terminal mode; then `q` or `<leader>t` hides the terminal |
| `<leader>R` | save and run the current file with bash |

## Git

| Key | |
|---|---|
| `<leader>gp` | preview the git change under the cursor |
| `<leader>gt` | toggle inline git blame for the current line |
| `<leader>gv` | toggle a side-by-side diff against HEAD |
| `<leader>lg` | open lazygit |

## File types

| Key | |
|---|---|
| `<leader>mr` | toggle in-buffer markdown rendering |
| `<leader>cv` | toggle the aligned CSV/TSV view |

## tmux

Prefix is `<C-s>`. After the prefix: `|` splits side by side, `-` splits top/bottom,
`d` detaches, `r` reloads the config, `I` installs plugins.
