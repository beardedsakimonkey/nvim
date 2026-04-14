vim.opt_local.formatoptions:append('t') -- autowrap using textwidth
vim.opt_local.formatoptions:remove('l') -- break long lines
vim.opt_local.breakindent = true -- auto-indent wrapped lines
vim.opt_local.expandtab = true
vim.opt_local.conceallevel = 3
vim.opt_local.textwidth = 80

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or 'exe')
    ..  ' | setl formatoptions< | setl formatoptions< | setl breakindent< | setl expandtab< | setl conceallevel< | setl textwidth<'
