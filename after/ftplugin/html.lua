vim.opt_local.formatprg = 'tidy -quiet -indent -ashtml -utf8'

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or 'exe') ..  ' | setl formatprg<'
