-- Disabling because it breaks :so
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

function _G.require_safe(mod)
    local ok, msg = xpcall(function() return require(mod) end, debug.traceback)
    if not ok then
        vim.api.nvim_err_writeln(('Error requiring %s: %s'):format(mod, msg))
    end
end

require_safe 'globals'
require_safe 'commands'
require_safe 'autocmds'
require_safe 'options'
require_safe 'statusline'
require_safe 'mappings'
require_safe 'plugins'
require_safe 'lsp'

-- After setting up globals so they're available to ftplugin / colorscheme files
vim.cmd 'colorscheme papyrus'
vim.cmd 'syntax enable'  -- see :h syntax-loading
