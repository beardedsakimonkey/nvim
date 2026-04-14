-- The default keywordprg uses the `run-help` zsh module which kinda sucks.
vim.opt_local.keywordprg = ':vert Man'

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or 'exe') ..  ' | setl keywordprg<'
