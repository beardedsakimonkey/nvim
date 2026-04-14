vim.opt_local.statusline = ' %f'

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or 'exe') ..  ' | setl statusline<'
