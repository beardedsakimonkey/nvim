vim.opt_local.keywordprg = 'help'
map('n', 'q', '<Cmd>lclose<Bar>q<CR>', {buffer = true, nowait = true, silent = true})
map('n', '<CR>', '<C-]>', {buffer = true})
-- Adapted from gpanders' config
map('n', 'u', '<C-u>', {buffer = true, nowait = true})
map('n', 'd', '<C-d>', {buffer = true, nowait = true})
map('n', 'U', '<C-b>', {buffer = true, nowait = true})
map('n', 'D', '<C-f>', {buffer = true, nowait = true})
map('n', '<Tab>', "<Cmd>call search('\\C\\%>1l\\f\\+([1-9][a-z]\\=)\\ze\\_.\\+\\%$')<CR>", {buffer = true})
map('n', '<S-Tab>', "<Cmd>call search('\\C\\%>1l\\f\\+([1-9][a-z]\\=)\\ze\\_.\\+\\%$', 'b')<CR>", {buffer = true})

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or 'exe')
    ..  ' | setl keywordprg< | sil! nun <buffer> q | sil! nun <buffer> <CR> | sil! nun <buffer> u | sil! nun <buffer> d | sil! nun <buffer> U | sil! nun <buffer> D | sil! nun <buffer> <Tab> | sil! nun <buffer> <S-Tab>'
