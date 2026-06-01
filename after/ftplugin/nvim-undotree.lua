vim.keymap.set('n', 'q', '<Cmd>q<CR>', {buffer = true, silent = true})

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or 'exe') ..  ' | sil! nun <buffer> q'
