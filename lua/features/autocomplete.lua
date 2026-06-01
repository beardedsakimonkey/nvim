-- Command-line autocompletion

vim.opt.wildmode = 'noselect:lastused,full'
vim.opt.wildoptions = 'pum'

local au = aug'my/autocomplete'
au('CmdlineChanged', ':', 'call wildtrigger()')

-- retain normal command-line history navigation with Up/Down
map('c', '<Up>',   'wildmenumode() ? "<C-E><Up>"   : "<Up>"', {expr = true})
map('c', '<Down>', 'wildmenumode() ? "<C-E><Down>" : "<Down>"', {expr = true})
