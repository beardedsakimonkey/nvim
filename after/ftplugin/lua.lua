local function goto_require()
    local mod_name = vim.fn.expand('<cword>')
    -- Adapted from $VIMRUNTIME/lua/vim/_load_package.lua
    local basename = mod_name:gsub('%.', '/')
    local paths = {
        'lua/' .. basename .. '.lua',
        'lua/' .. basename .. '/init.lua',
    }
    local found = vim.api.nvim__get_runtime(paths, false, {is_lua = true})
    if #found > 0 then
        local path = found[1]
        vim.cmd('edit ' .. fe(path))
    else
        vim.api.nvim_err_writeln('Cannot find module ' .. basename)
    end
end

vim.opt_local.keywordprg = ':help'
vim.opt_local.textwidth = 80
map('n', 'gd', goto_require, {buffer = true})

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or 'exe')
    ..  ' | setl keywordprg< | setl textwidth< | sil! nun <buffer> gd'
