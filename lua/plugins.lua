local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({
    -- Trusted
    { src = gh'beardedsakimonkey/nvim-udir', version = 'develop' },
    { src = gh'beardedsakimonkey/nvim-ufind' },
    -- Untrusted
    { src = gh'echasnovski/mini.operators',  version = 'stable' },
    { src = gh'echasnovski/mini.bufremove',  version = 'stable' },
    { src = gh'echasnovski/mini.hipatterns', version = 'stable' },
    { src = gh'echasnovski/mini.diff',       version = 'stable' },
    { src = gh'tpope/vim-sleuth',            version = 'be69bff86754b1aa5adcbb527d7fcd1635a84080' },
    { src = gh'kylechui/nvim-surround',      version = '2e93e154de9ff326def6480a4358bfc149d5da2c' },
    { src = gh'AndrewRadev/linediff.vim',    version = '245d16328c47a132574e0fa4298d24a0f78b20b0' },
    { src = gh'MaxMEllon/vim-jsx-pretty',    version = '6989f1663cc03d7da72b5ef1c03f87e6ddb70b41' },
    { src = gh'DingDean/wgsl.vim',           version = 'bb6516e0356e81cc10a885e63273ef1d63cc74b1' },
    { src = gh'0x96f-org/0x96f.nvim',        version = '188c2be71a4e046df7cea095ccd61a520ee21249' },
})
require_safe 'config.udir'
require_safe 'config.ufind'
require_safe 'config.mini'

-- Neovim ---------------------------------------------------------------------
stub_com('Undotree', 'nvim.undotree')
stub_com('DiffTool', 'nvim.difftool', {nargs = '*', complete = 'file'})

-- linediff -------------------------------------------------------------------
vim.g.linediff_buffer_type = 'scratch'
map('x', 'D', "mode() is# 'V' ? ':Linediff<cr>' : 'D'", {expr = true})

-- nvim-surround --------------------------------------------------------------
require'nvim-surround'.setup({ indent_lines = false })
