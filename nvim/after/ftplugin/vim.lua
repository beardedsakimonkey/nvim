vim.opt_local.iskeyword:append(':')

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or 'exe') ..  ' | setl iskeyword<'
