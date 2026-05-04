local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({
    -- Trusted
    { src = gh'beardedsakimonkey/nvim-udir', version = 'develop' },
    { src = gh'beardedsakimonkey/nvim-ufind' },
    -- Untrusted
    { src = gh'echasnovski/mini.operators',  version = 'stable' },
    { src = gh'echasnovski/mini.bufremove',  version = 'stable' },
    { src = gh'echasnovski/mini.hipatterns', version = 'stable' },
    { src = gh'tpope/vim-sleuth',            version = 'be69bff86754b1aa5adcbb527d7fcd1635a84080' },
    { src = gh'kylechui/nvim-surround',      version = '633a0ab03159569a66b65671b0ffb1a6aed6cf18' },
    { src = gh'AndrewRadev/linediff.vim',    version = '245d16328c47a132574e0fa4298d24a0f78b20b0' },
    { src = gh'MaxMEllon/vim-jsx-pretty',    version = '6989f1663cc03d7da72b5ef1c03f87e6ddb70b41' },
    { src = gh'DingDean/wgsl.vim',           version = 'bb6516e0356e81cc10a885e63273ef1d63cc74b1' },
    { src = gh'0x96f-org/0x96f.nvim',        version = '188c2be71a4e046df7cea095ccd61a520ee21249' },
})

require_safe 'config.udir'
require_safe 'config.ufind'

-- linediff -------------------------------------------------------------------
vim.g.linediff_buffer_type = 'scratch'
map('x', 'D', "mode() is# 'V' ? ':Linediff<cr>' : 'D'", {expr = true})

-- nvim-surround --------------------------------------------------------------
require'nvim-surround'.setup{
    indent_lines = false,
}

-- mini.hipatterns ------------------------------------------------------------
local color_map

local function enable_hipatterns(opts)
    local hipatterns = require'mini.hipatterns'
    hipatterns.enable(opts.buf, {
        highlighters = {
            hex_color = hipatterns.gen_highlighter.hex_color(),
            named_color = {
                pattern = '%w+',
                group = function(_, match)
                    local color = color_map[match]
                    if color == nil then return nil end
                    return hipatterns.compute_hex_color_group(color, 'bg')
                end
            },
        },
    })
end

local au = aug'my/hipatterns'
au('BufEnter', {'papyrus.lua', 'rgb.txt', '*.css'}, function(opts)
    color_map = color_map or vim.tbl_map(
        function(dec) return string.format('#%06x', dec) end,
        vim.api.nvim_get_color_map()
    )
    enable_hipatterns(opts)
end)
-- Sourcing colorscheme invokes `:hi clear`, which clears mini's highlight
-- groups.
au('BufWritePost', 'papyrus.lua', function(opts)
    package.loaded['mini.hipatterns'] = nil
    enable_hipatterns(opts)
end)

-- mini.operators -------------------------------------------------------------
require('mini.operators').setup({
    evaluate = { prefix = 'g=' },
    exchange = { prefix = 'gx' },
    multiply = { prefix = 'gm' },
    replace  = { prefix = 'gr' },
    sort     = { prefix = 'gs' }
})
