vim.opt_local.formatprg = 'python -m json.tool'

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or 'exe') ..  ' | setl formatprg<'
