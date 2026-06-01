-- vim.loader.enable()

-- In $VIMRUNTIME/plugin/
vim.g.loaded_matchit = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_remote_plugins = 1
vim.g.loaded_spellfile_plugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_tutor_mode_plugin = 1

-- In $VIMRUNTIME/autoload/provider/
vim.g.loaded_node_provider = 1
vim.g.loaded_perl_provider = 1
vim.g.loaded_python_provider = 1
vim.g.loaded_python3_provider = 1
vim.g.loaded_ruby_provider = 1

require 'globals'
require 'commands'
require 'autocmds'
require 'options'
require 'statusline'
require 'mappings'
require 'plugins'
require 'lsp'
require 'features.pack'
require 'features.terminal'
require 'features.hlsearch'
require 'features.autocomplete'
require 'features.ghostty_theme'.apply()

-- After setting up globals so they're available to ftplugin / colorscheme files
vim.cmd 'syntax enable'  -- see :h syntax-loading

require'vim._core.ui2'.enable({enable = true})
