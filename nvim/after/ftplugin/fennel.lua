local exists = require('util').exists

local function goto_lua()
    local from = vim.fn.expand('%:p')
    local to = from:gsub('%.fnl$', '.lua')
    if exists(to) then
        vim.cmd('edit ' .. fe(to))
    else
        vim.api.nvim_err_writeln('Cannot read file ' .. to)
    end
end


vim.opt_local.expandtab = true
vim.opt_local.commentstring = ';; %s'
vim.opt_local.keywordprg = ':help'
vim.opt_local.iskeyword:remove('.')
vim.opt_local.iskeyword:remove(':')
vim.opt_local.iskeyword:remove(']')
vim.opt_local.iskeyword:remove('[')
vim.keymap.set('n', ']f', goto_lua, {buffer = true})
vim.keymap.set('n', '[f', goto_lua, {buffer = true})

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or 'exe')
    ..  ' | setl expandtab< | setl commentstring< | setl keywordprg< | setl iskeyword< | sil! nun <buffer> ]f | sil! nun <buffer> [f'
