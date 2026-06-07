-- Command-line autocompletion
-- see :h cmdline-autocompletion

local au = aug'my/autocomplete'
au('CmdlineChanged', ':', 'call wildtrigger()')
vim.opt.wildmode = 'noselect:lastused,full'
vim.opt.wildoptions = 'pum'

-- retain normal cursor movevement with Left/Right
vim.cmd[[cnoremap <expr> <Left>  wildmenumode() ? "\<C-E>\<Left>"  : "\<Left>"]]
vim.cmd[[cnoremap <expr> <Right> wildmenumode() ? "\<C-E>\<Right>" : "\<Right>"]]

vim.cmd[[
    set findfunc=Find
    func! Find(arg, _)
      if empty(s:filescache)
        let s:filescache = globpath('.', '**', 1, 1)
        call filter(s:filescache, '!isdirectory(v:val)')
        call map(s:filescache, "fnamemodify(v:val, ':.')")
      endif
      return a:arg == '' ? s:filescache : matchfuzzy(s:filescache, a:arg)
    endfunc
    let s:filescache = []
    autocmd CmdlineEnter : let s:filescache = []
]]
