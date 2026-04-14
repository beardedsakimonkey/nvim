vim.opt_local.commentstring = '// %s'
vim.opt_local.ts = 8
vim.opt_local.cinoptions = 'l1'  -- better switch case indenting
vim.opt_local.keywordprg = ':vert Man'
vim.opt_local.expandtab = true

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or 'exe')
    .. ' | setl commentstring< | setl ts< | setl cinoptions< | setl keywordprg< | setl expandtab<'
