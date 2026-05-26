local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({
    -- Trusted
    { src = gh'beardedsakimonkey/nvim-dirtree' },
    { src = gh'beardedsakimonkey/nvim-ufind' },
    -- Untrusted
    { src = gh'echasnovski/mini.operators',  version = 'stable' },
    { src = gh'echasnovski/mini.bufremove',  version = 'stable' },
    { src = gh'echasnovski/mini.hipatterns', version = 'stable' },
    { src = gh'echasnovski/mini.diff',       version = 'stable' },
    { src = gh'echasnovski/mini-git',        version = 'stable' },
    { src = gh'tpope/vim-sleuth',            version = 'be69bff86754b1aa5adcbb527d7fcd1635a84080' },
    { src = gh'kylechui/nvim-surround',      version = '2e93e154de9ff326def6480a4358bfc149d5da2c' },
    { src = gh'AndrewRadev/linediff.vim',    version = '245d16328c47a132574e0fa4298d24a0f78b20b0' },
    { src = gh'MaxMEllon/vim-jsx-pretty',    version = '6989f1663cc03d7da72b5ef1c03f87e6ddb70b41' },
    { src = gh'DingDean/wgsl.vim',           version = 'bb6516e0356e81cc10a885e63273ef1d63cc74b1' },
    { src = gh'rebelot/kanagawa.nvim',       version = 'bb85e4bfc8d89b0e62c8fa53ccdd13d12e2f77b3' },
    { src = gh'loctvl842/monokai-pro.nvim',  version = 'a68e38b8e55d69a215d0f02598900a79c356da9d' },
    { src = gh'sonph/onehalf',               version = '75eb2e97acd74660779fed8380989ee7891eec56' },
    { src = gh'kaarmu/typst.vim',            version = '1d5436c0f55490893892441c0eca55e6cdf4916c' },
}, { confirm = false })

local onehalf = vim.pack.get({ 'onehalf' }, { info = false })[1]
if onehalf then
    vim.opt.runtimepath:prepend(onehalf.path .. '/vim')
end

require_safe 'config.dirtree'
require_safe 'config.ufind'
require_safe 'config.mini'
require_safe 'features.pack'
require_safe 'features.terminal'
require_safe 'features.hlsearch'
local theme = require_safe 'features.ghostty_theme'
if theme ~= nil then
    theme.apply()
else
    vim.cmd 'colo onehalfdark'
end

-- Neovim ---------------------------------------------------------------------
stub_com('Undotree', 'nvim.undotree')
stub_com('DiffTool', 'nvim.difftool', {nargs = '*', complete = 'file'})

-- linediff -------------------------------------------------------------------
vim.g.linediff_buffer_type = 'scratch'
map('x', 'D', "mode() is# 'V' ? ':Linediff<cr>' : 'D'", {expr = true})

-- nvim-surround --------------------------------------------------------------
require'nvim-surround'.setup({ indent_lines = false })
