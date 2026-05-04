local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({
    { src = gh'beardedsakimonkey/nvim-udir',   version = 'develop' },
    gh'beardedsakimonkey/nvim-ufind',
    gh'tpope/vim-sleuth',
    { src = gh'kylechui/nvim-surround',        version = '633a0ab03159569a66b65671b0ffb1a6aed6cf18' },
    { src = gh'AndrewRadev/linediff.vim',       version = '245d16328c47a132574e0fa4298d24a0f78b20b0' },
    { src = gh'echasnovski/mini.operators',     version = 'e5f97b0edcd871615fd82339f329794f0e419894' },
    gh'echasnovski/mini.hipatterns',
    gh'MaxMEllon/vim-jsx-pretty',
    gh'DingDean/wgsl.vim',
    gh'0x96f-org/0x96f.nvim',
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
