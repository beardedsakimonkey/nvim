vim.opt_local.scrolloff = 0
vim.keymap.set("n", "q", "<Cmd>q<CR>", {buffer = true})
-- Adapted from gpanders' config
vim.keymap.set("n", "u", "<C-u>", {buffer = true, nowait = true})
vim.keymap.set("n", "d", "<C-d>", {buffer = true, nowait = true})
vim.keymap.set("n", "U", "<C-b>", {buffer = true, nowait = true})
vim.keymap.set("n", "D", "<C-f>", {buffer = true, nowait = true})
vim.keymap.set("n", "<Tab>", "<Cmd>call search('\\v[\\|\\*]\\S{-}[\\|\\*]')<CR>", {buffer = true, silent = true})
vim.keymap.set("n", "<S-Tab>", "<Cmd>call search('\\v[\\|\\*]\\S{-}[\\|\\*]', 'b')<CR>", {buffer = true, silent = true})
vim.keymap.set("n", "<CR>", "g<C-]>", {buffer = true})

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or 'exe')
    ..  " | setl scrolloff< | sil! nun <buffer> q | sil! nun <buffer> u | sil! nun <buffer> d | sil! nun <buffer> U | sil! nun <buffer> D | sil! nun <buffer> <Tab> | sil! nun <buffer> <S-Tab> | sil! nun <buffer> <CR>"
