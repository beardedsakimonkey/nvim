vim.opt_local.textwidth = 80

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or 'exe') .. ' | setl tw<'
