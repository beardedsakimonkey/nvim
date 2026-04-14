vim.opt_local.formatoptions:append('t')
vim.opt_local.textwidth = 80
vim.opt_local.colorcolumn = '80'

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or 'exe')
    ..  ' | setl formatoptions< | setl textwidth< | setl colorcolumn<'
