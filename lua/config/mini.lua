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

local au = aug'my/mini'
au('BufEnter', {'papyrus.lua', 'rgb.txt', '*.css'}, function(opts)
    -- Highlight hexadecimal colors
    color_map = color_map or vim.tbl_map(
        function(dec) return string.format('#%06x', dec) end,
        vim.api.nvim_get_color_map()
    )
    enable_hipatterns(opts)
end)

-- Sourcing colorscheme calls `:hi clear`, which clears mini's highlight groups
au('BufWritePost', 'papyrus.lua', function(opts)
    package.loaded['mini.hipatterns'] = nil
    enable_hipatterns(opts)
end)

-- mini.operators -------------------------------------------------------------
require('mini.operators').setup({
    evaluate = { prefix = 'g=' },
    exchange = { prefix = 'cx' },
    multiply = { prefix = 'gm' },
    replace  = { prefix = 'gr' },
    sort     = { prefix = 'gs' }
})

require('mini.operators').make_mappings(
    'exchange',
    { textobject = 'cx', line = 'cxx', selection = 'X' }
)

-- mini.diff ------------------------------------------------------------------
require('mini.diff').setup({
  mappings = {
    apply = 'gh',
    reset = 'gH',
    textobject = 'gh',
    goto_first = '[H',
    goto_prev = '[h',
    goto_next = ']h',
    goto_last = ']H',
  },
})
map('n', 'god', function() require'mini.diff'.toggle_overlay() end)

-- mini.git -------------------------------------------------------------------
require('mini.git').setup({
    command = {
        split = 'auto',
    },
})
