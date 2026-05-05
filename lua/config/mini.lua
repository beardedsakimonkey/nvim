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

--[[
    - `vip` followed by `gh` / `gH` applies/resets hunks inside current paragraph. Same can be achieved in operator form `ghip` / `gHip`, which has the advantage of being dot-repeatable.
    - `ghgh` / `gHgh` applies/resets hunk under cursor.
    - `dgh` deletes hunk under cursor.
--]]
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
require('mini.git').setup()

local align_blame = function(au_data)
    if au_data.data.git_subcommand ~= 'blame' then return end

    -- Align blame output with source
    local win_src = au_data.data.win_source
    vim.wo.wrap = false
    vim.fn.winrestview({ topline = vim.fn.line('w0', win_src) })
    vim.api.nvim_win_set_cursor(0, { vim.fn.line('.', win_src), 0 })

    -- Bind both windows so that they scroll together
    vim.wo[win_src].scrollbind, vim.wo.scrollbind = true, true
end

-- au('User', 'MiniGitCommandSplit', align_blame)
vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniGitCommandSplit',
    callback = align_blame,
})

map({'n', 'x'}, '<space>gs', '<Cmd>lua MiniGit.show_at_cursor()<CR>')
map({'n', 'x'}, '<space>gr', '<Cmd>lua MiniGit.show_range_history()<CR>')
map({'n', 'x'}, '<space>gd', '<Cmd>lua MiniGit.show_diff_source()<CR>')
