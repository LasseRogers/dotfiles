# Commands

Typed in normal mode after `:`. `<Tab>` completes, `<Up>` recalls earlier commands.

| Command | |
|---|---|
| `:w` / `:wa` | save / save all |
| `:q` / `:qa` / `:q!` | quit / quit all / quit without saving |
| `:e file` | open or create a file |
| `:42` | jump to line 42 |
| `:%s/old/new/g` | replace all in the file (`gc` to confirm each) |
| `:vsplit` / `:split` | split the window side by side / top-bottom |
| `:cmd1 \| cmd2` | run two commands in a row, e.g. `:vsplit \| term` or `:vsplit \| e file` |
| `:Lazy` | manage plugins |
| `:Mason` | manage language servers and formatters |
| `:checkhealth` | diagnose problems |
| `:help topic` | built-in docs |
