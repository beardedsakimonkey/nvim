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
map('n', 'god', function() require'mini.diff'.toggle_overlay() vim.api.nvim_feedkeys('zz', 'n', true) end)
map('n', 'gon', function() require'mini.diff'.toggle_overlay() vim.api.nvim_feedkeys('zz', 'n', true) end)

local function open_git_diff_hunks()
    local diff = require'mini.diff'
    local root = vim.fn.systemlist({'git', 'rev-parse', '--show-toplevel'})[1]
    if vim.v.shell_error ~= 0 or root == nil or root == '' then
        vim.notify('Not in a git repository', vim.log.levels.WARN)
        return
    end

    local files = vim.fn.systemlist({'git', '-C', root, 'diff', '--name-only'})
    if vim.v.shell_error ~= 0 then
        vim.notify('git diff failed', vim.log.levels.ERROR)
        return
    end
    if #files == 0 then
        vim.notify('No changed files', vim.log.levels.INFO)
        return
    end

    local bufs = {}
    for _, file in ipairs(files) do
        local path = root .. '/' .. file
        local buf = vim.fn.bufnr(path, true)
        vim.bo[buf].buflisted = true
        vim.fn.bufload(buf)
        diff.enable(buf)
        table.insert(bufs, buf)
    end

    local function export_hunks(attempt)
        local pending = vim.tbl_filter(function(buf)
            local data = diff.get_buf_data(buf)
            return data ~= nil and data.ref_text == nil
        end, bufs)

        if #pending > 0 and attempt < 20 then
            vim.defer_fn(function() export_hunks(attempt + 1) end, 50)
            return
        end

        local wanted = {}
        for _, buf in ipairs(bufs) do
            wanted[buf] = true
        end
        local items = vim.tbl_filter(function(item)
            return wanted[item.bufnr]
        end, diff.export('qf', { scope = 'all' }))
        vim.fn.setqflist({}, ' ', { title = 'Git diff hunks', items = items })
        if #items == 0 then
            vim.notify('No hunks found', vim.log.levels.INFO)
        else
            vim.cmd('copen')
        end
    end

    export_hunks(0)
end

map('n', '<space>gq', open_git_diff_hunks)

-- mini.git -------------------------------------------------------------------
require('mini.git').setup()

map({'n', 'x'}, '<space>gs', '<Cmd>lua MiniGit.show_at_cursor()<CR>')
map({'n', 'x'}, '<space>gh', '<Cmd>lua MiniGit.show_range_history()<CR>')
-- map({'n', 'x'}, '<space>gd', '<Cmd>lua MiniGit.show_diff_source()<CR>')

map('n', '<space>gc', '<Cmd>silent vert Git commit -a<CR>')
map('n', '<space>gC', '<Cmd>silent vert Git commit --amend --reuse-message=HEAD<CR>')
map('n', '<space>gb', '<Cmd>leftabove vert Git blame %<CR>')
map('n', '<space>gl', '<Cmd>vert Git log<CR>')
map('n', '<space>gd', '<Cmd>Git diff<CR>')

au('User', 'MiniGitCommandSplit', function(au_data)
    if au_data.data.git_subcommand ~= 'blame' then return end

    vim.api.nvim_win_call(au_data.data.win_stdout, function()
        vim.cmd('vertical resize 45')
        vim.wo.winfixwidth = true
    end)

    -- Align blame output with source
    local win_src = au_data.data.win_source
    vim.wo.wrap = false
    vim.fn.winrestview({ topline = vim.fn.line('w0', win_src) })
    vim.api.nvim_win_set_cursor(0, { vim.fn.line('.', win_src), 0 })

    -- Bind both windows so that they scroll together
    vim.wo[win_src].scrollbind, vim.wo.scrollbind = true, true
end)
