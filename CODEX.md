# Neovim Context

## Useful Paths

- Config root: `/Users/tim/.config/nvim`
- Neovim docs: `/opt/homebrew/Cellar/neovim/0.12.1/share/nvim/runtime/doc/`

## Project Structure

- `init.lua` is the bootstrap entrypoint.
- `lua/globals.lua` is foundational. It defines shared helpers used across the config:
  - `com()` for user commands
  - `aug()` for autocmd groups and `au()` helpers
  - `map()` as the shared keymap wrapper
  - utility globals like `fe()`, `se()`, and `cc()`
- `lua/globals.lua` loads before most other Lua modules, so changes there affect the rest of the config.
- `lua/options.lua` sets global editor options.
- `lua/autocmds.lua` wires event-driven behavior.
- `lua/commands.lua` defines custom Ex commands.
- `lua/mappings.lua` defines normal/insert/visual mappings.
- `lua/lsp.lua` owns LSP diagnostics, attach behavior, and LSP-specific commands.
- `plugin/session.vim` handles session tracking and restoration.
