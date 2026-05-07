# Repository Guidelines

## Project Structure & Module Organization

This repository is a personal Neovim configuration. `init.lua` is the bootstrap entrypoint and loads the main Lua modules with `require_safe`. Core behavior lives in `lua/`: `globals.lua` defines shared helpers, `options.lua` sets editor options, `mappings.lua` owns keymaps, `commands.lua` defines user commands, `autocmds.lua` wires events, `lsp.lua` owns LSP behavior, and `statusline.lua` builds the statusline. Plugin setup is in `lua/plugins.lua`, with plugin-specific configuration in `lua/config/` and feature modules in `lua/features/`. Runtime additions live in `after/ftplugin/` and `after/queries/`; colorschemes live in `colors/`; legacy Vimscript plugins live in `plugin/`.

## Build, Test, and Development Commands

- `nvim --headless "+quit"`: smoke-test startup and plugin loading.
- `nvim --headless -u init.lua "+lua require('plugins')" "+quit"`: check plugin declarations load.
- `nvim --headless "+checkhealth" "+quit"`: run Neovim health checks when changing providers, LSP, or plugins.
- `git diff --check`: detect trailing whitespace and patch formatting issues before committing.

There is no separate build step; changes are exercised by starting Neovim with this config.

## Coding Style & Naming Conventions

Use Lua for new configuration unless modifying an existing Vimscript file. Follow the current style: four-space indentation in Lua, compact single-purpose modules, single-quoted strings where practical, and local helpers before exported behavior. Keep shared primitives in `lua/globals.lua` rare and intentional because that file loads early and affects the whole config. Name feature modules by behavior, for example `lua/features/terminal.lua`, and filetype overrides by filetype, for example `after/ftplugin/rust.lua`.

## Testing Guidelines

No formal test framework is present. Validate changes with headless Neovim startup, then manually exercise the affected workflow in an interactive Neovim session. For filetype changes, open a representative file and confirm buffer-local options, maps, syntax queries, or commands only apply to that filetype.

## Agent-Specific Instructions

Avoid broad refactors while editing this config. Preserve existing user mappings and command names unless the task explicitly asks to change them. When touching plugin declarations, keep `nvim-pack-lock.json` consistent with the resulting plugin state.

## Useful Paths

- Neovim docs: `/opt/homebrew/Cellar/neovim/0.12.1/share/nvim/runtime/doc/`
