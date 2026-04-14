vim.opt.termguicolors = true
vim.opt.shada = "!,'1024,<0,s8,:128,/8,@8,f0,h,r/tmp,rterm:,rman:"
vim.opt.sessionoptions = {'help', 'tabpages', 'winsize', 'curdir', 'folds'}

vim.opt.ttimeoutlen = 0  -- avoid confusing <esc>-key with <a-…>
vim.opt.timeoutlen = 3000
vim.opt.synmaxcol = 500

vim.opt.confirm = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.splitright = true
vim.opt.splitbelow = true
-- vim.opt.splitkeep = 'screen'
vim.opt.winminheight = 0
vim.opt.winminwidth = 0

vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.shiftround = true
vim.opt.smarttab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = -1

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.infercase = true
vim.opt.smartcase = true

vim.opt.completeopt = {'menu'}
vim.opt.complete = {'.', 'i'}
vim.opt.wildmenu = true
vim.opt.wildignorecase = true
vim.opt.wildignore = {'*.o', '*/node_modules/*'}
vim.opt.fileignorecase = false

vim.opt.foldmethod = 'expr'
vim.opt.foldlevelstart = 99
vim.opt.foldopen:remove('block')
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'

vim.opt.modeline = false
vim.opt.shortmess = 'filnxtToOfaTWIcFS'
vim.opt.fillchars = {eob = ' '}
vim.opt.list = true
vim.opt.colorcolumn = '+0'

vim.opt.scrolloff = 2
vim.opt.sidescrolloff = 2
vim.opt.virtualedit = 'block'
vim.opt.wrap = false

vim.opt.number = true
vim.opt.showmode = false
vim.opt.cursorline = true
vim.opt.ruler = false  -- don't echo anything when entering a floating window
vim.opt.jumpoptions = 'view'

vim.opt.diffopt:append('linematch:60')  -- better diff
