vim.keymap.set('n', 'q', '<Cmd>q<CR>', {buffer = true, silent = true})
vim.keymap.set('n', '<CR>', '<CR>', {buffer = true}) -- undo any existing <CR> mapping
vim.opt_local.statusline = " %q %{printf(\" %d line%s\", line(\"$\"), line(\"$\") > 1 ? \"s \" : \" \")}"

-- Adapted from gpanders' config
if vim.g.loaded_cfilter ~= 1 then
    vim.cmd 'sil! packadd cfilter'
    vim.g.loaded_cfilter = 1
end

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or 'exe')
    ..  ' | sil! nun <buffer> q | sil! nun <buffer> <CR> | setl statusline<'
