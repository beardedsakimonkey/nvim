local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({
    -- Trusted
    gh'beardedsakimonkey/nvim-dora',
    gh'beardedsakimonkey/nvim-ufind',

    -- Untrusted
    { src = gh'echasnovski/mini.operators',  version = 'stable' },
    { src = gh'echasnovski/mini.bufremove',  version = 'stable' },
    { src = gh'echasnovski/mini.hipatterns', version = 'stable' },
    { src = gh'echasnovski/mini.diff',       version = 'stable' },
    { src = gh'tpope/vim-fugitive',          version = '3b753cf8c6a4dcde6edee8827d464ba9b8c4a6f0' },
    { src = gh'tpope/vim-sleuth',            version = 'be69bff86754b1aa5adcbb527d7fcd1635a84080' },
    { src = gh'github/copilot.vim',          version = 'a12fd5672110c8aa7e3c8419e28c96943ca179be' },
    { src = gh'kylechui/nvim-surround',      version = '2e93e154de9ff326def6480a4358bfc149d5da2c' },
    { src = gh'AndrewRadev/linediff.vim',    version = '245d16328c47a132574e0fa4298d24a0f78b20b0' },
    { src = gh'andymass/vim-matchup',        version = 'a2d618496223386844acb5a6763cfc3cc1357af1' },

    -- Filetypes
    { src = gh'DingDean/wgsl.vim',           version = 'bb6516e0356e81cc10a885e63273ef1d63cc74b1' },
    { src = gh'kaarmu/typst.vim',            version = '1d5436c0f55490893892441c0eca55e6cdf4916c' },
    { src = gh'MaxMEllon/vim-jsx-pretty',    version = '6989f1663cc03d7da72b5ef1c03f87e6ddb70b41' },

    -- Colorschemes
    { src = gh'rebelot/kanagawa.nvim',       version = 'bb85e4bfc8d89b0e62c8fa53ccdd13d12e2f77b3' },
    { src = gh'loctvl842/monokai-pro.nvim',  version = 'a68e38b8e55d69a215d0f02598900a79c356da9d' },
    { src = gh'ClearAspect/onehalf',         version = 'cb25877a6aada5ef98681950b85bd9f9f7f29a59' },

}, { confirm = true })

require 'config.dora'
require 'config.ufind'
require 'config.mini'

-- Neovim ---------------------------------------------------------------------
stub_com('Undotree', 'nvim.undotree')
stub_com('DiffTool', 'nvim.difftool', {nargs = '*', complete = 'file'})

-- linediff -------------------------------------------------------------------
vim.g.linediff_buffer_type = 'scratch'
map('x', 'D', "mode() is# 'V' ? ':Linediff<cr>' : 'D'", {expr = true})

-- nvim-surround --------------------------------------------------------------
require'nvim-surround'.setup({ indent_lines = false })

-- vim-matchup ----------------------------------------------------------------
map({'n', 'x', 'o'}, '<Tab>',   '<Plug>(matchup-%)',  {remap = true})
map({'n', 'x', 'o'}, '<S-Tab>', '<Plug>(matchup-g%)', {remap = true})
