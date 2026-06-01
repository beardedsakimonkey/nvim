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
    - Visual mode `gh` / `gH` applies/resets hunks inside current paragraph.
      Same can be achieved in operator form `ghip` / `gHip`, which has the advantage of being dot-repeatable.
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
map('n', 'god', function()
    require'mini.diff'.toggle_overlay(0)
    vim.api.nvim_feedkeys('zz', 'n', true)
end)

local function open_current_file_diff()
    local buf = vim.api.nvim_get_current_buf()
    local path = vim.api.nvim_buf_get_name(buf)
    if path == '' then
        vim.notify('No current file to diff', vim.log.levels.WARN)
        return
    end

    local mini_diff = require'mini.diff'
    local data = mini_diff.get_buf_data(buf)
    if data == nil then
        mini_diff.enable(buf)
        data = mini_diff.get_buf_data(buf)
    end
    if data == nil or data.ref_text == nil then
        vim.notify('No diff source for current file', vim.log.levels.WARN)
        return
    end

    local ref_buf = vim.api.nvim_create_buf(false, true)
    local lines = vim.split(data.ref_text, '\n', {plain = true})
    if lines[#lines] == '' then table.remove(lines) end
    vim.api.nvim_buf_set_lines(ref_buf, 0, -1, false, lines)
    vim.bo[ref_buf].buftype = 'nofile'
    vim.bo[ref_buf].bufhidden = 'wipe'
    vim.bo[ref_buf].swapfile = false
    vim.bo[ref_buf].filetype = vim.bo[buf].filetype
    vim.bo[ref_buf].modifiable = false

    local file_name = vim.fn.fnamemodify(path, ':t')
    vim.api.nvim_buf_set_name(ref_buf, 'minidiff://' .. buf .. '/' .. file_name .. '/index/' .. vim.uv.hrtime())

    local win = vim.api.nvim_get_current_win()
    vim.cmd('leftabove vertical split')
    local ref_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(ref_win, ref_buf)
    vim.api.nvim_win_set_buf(win, buf)

    vim.api.nvim_win_call(ref_win, vim.cmd.diffthis)
    vim.api.nvim_win_call(win, vim.cmd.diffthis)
    vim.api.nvim_set_current_win(win)

    local group = vim.api.nvim_create_augroup('my/mini/diff-view/' .. ref_buf, {clear = true})
    local cleaning = false
    local function cleanup()
        if cleaning then return end
        cleaning = true
        pcall(vim.api.nvim_del_augroup_by_id, group)

        for _, diff_win in ipairs({ ref_win, win }) do
            if vim.api.nvim_win_is_valid(diff_win) then
                vim.api.nvim_win_call(diff_win, function()
                    vim.cmd('diffoff')
                    vim.cmd('close')
                end)
            end
        end
    end

    for _, diff_win in ipairs({ ref_win, win }) do
        vim.api.nvim_create_autocmd('WinClosed', {
            group = group,
            pattern = tostring(diff_win),
            callback = cleanup,
        })
    end
end

map('n', '<space>gd', open_current_file_diff)


-- mini.git -------------------------------------------------------------------
require('mini.git').setup()

map({'n', 'x'}, '<space>gs', '<Cmd>lua MiniGit.show_at_cursor()<CR>')
map({'n', 'x'}, '<space>gh', '<Cmd>lua MiniGit.show_range_history()<CR>')

map('n', '<space>gc', '<Cmd>silent vert Git commit -a<CR>')
map('n', '<space>gC', '<Cmd>silent vert Git commit --amend --reuse-message=HEAD<CR>')
map('n', '<space>gb', '<Cmd>leftabove vert Git blame %<CR>')
map('n', '<space>gl', '<Cmd>vert Git log<CR>')

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

-- mini.files -----------------------------------------------------------------
-- require'mini.files'.setup({})
-- map('n', '-', '<Cmd>lua MiniFiles.open()<CR>')
