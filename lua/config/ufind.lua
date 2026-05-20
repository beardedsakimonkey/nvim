local ufind = require'ufind'
local util = require'util'
local uv = vim.uv
local Uf = require'ufind.Uf'

local function install_selection_hook()
    if Uf._config_selection_hook_installed then
        return
    end
    Uf._config_selection_hook_installed = true

    local new = Uf.new
    Uf.new = function(...)
        local uf = new(...)
        uf._config_on_select = Uf._config_next_on_select
        uf._config_on_scroll = Uf._config_next_on_scroll
        Uf._config_next_on_select = nil
        Uf._config_next_on_scroll = nil
        return uf
    end

    local function on_select(uf)
        if not uf._config_on_select then
            return
        end
        local ok, err = xpcall(uf._config_on_select, debug.traceback, uf)
        if not ok then
            uf._config_on_select = nil
            vim.notify(err, vim.log.levels.ERROR)
        end
    end

    local move_cursor_and_redraw = Uf.move_cursor_and_redraw
    Uf.move_cursor_and_redraw = function(self, ...)
        move_cursor_and_redraw(self, ...)
        on_select(self)
    end

    local redraw_results = Uf.redraw_results
    Uf.redraw_results = function(self, ...)
        redraw_results(self, ...)
        on_select(self)
    end

    local scroll_horizontally = Uf.scroll_horizontally
    Uf.scroll_horizontally = function(self, ...)
        if self._config_on_scroll then
            local ok, err = xpcall(self._config_on_scroll, debug.traceback, self, ...)
            if not ok then
                self._config_on_scroll = nil
                vim.notify(err, vim.log.levels.ERROR)
            end
            return
        end
        scroll_horizontally(self, ...)
    end
end

install_selection_hook()

local function with_picker_hooks(hooks, open)
    Uf._config_next_on_select = hooks.on_select
    Uf._config_next_on_scroll = hooks.on_scroll
    local ok, err = xpcall(open, debug.traceback)
    if not ok then
        Uf._config_next_on_select = nil
        Uf._config_next_on_scroll = nil
        error(err, 0)
    end
end

local function cfg(t)
    return vim.tbl_deep_extend('keep', t, {
        layout = { border = 'single' },
        keymaps = {
            actions = {
                vsplit = '<C-l>',
            }
        },
    })
end

local function on_complete_grep(action, results)
    local pat = '^([^:]-):(%d+):(%d+):(.*)$'
    if #results == 1 then -- open a single result
        local fname, linenr, colnr = results[1]:match(pat)
        if fname then
            -- HACK: if we don't schedule, the cursor gets positioned one
            -- column to the left.
            vim.schedule(function()
                -- edit the file at the appropriate line/column number
                vim.cmd(('%s +%s %s | norm! %s|'):format(
                        action, linenr, vim.fn.fnameescape(fname), colnr))
            end)
        end
    else -- put selected results into a quickfix list
        -- TODO: handle `action`?
        vim.fn.setqflist({}, ' ', {
            nr = '$', -- push to top of qf-list stack
            items = vim.tbl_map(function(result)
                local fname, linenr, colnr, line = result:match(pat)
                return fname and {
                    filename = fname,
                    text = line,
                    lnum = linenr,
                    col = colnr,
                } or {}
            end, results),
        })
        vim.cmd(action .. '| copen | cc!')
    end
end

local function live_grep()
    ufind.open_live('rg --vimgrep --fixed-strings --color=ansi -- ', cfg{
        ansi = true,
        on_complete = on_complete_grep,
    })
end

local function match_basename(str, query)
    str = str:lower()
    query = query:lower()
    local positions = require'ufind.helper.find_min_subsequence'(str, query) or {}
    if #positions < #query then
        return nil
    end
    local function calc_score(positions, str)
        local score = 0
        local prev_pos = -1
        for _, pos in ipairs(positions) do
            local consec = pos == prev_pos + 1
            if consec   then score = score + 2 end  -- consecutive char
            if pos == 1 then score = score + 1 end  -- start of word
            prev_pos = pos
        end
        return score
    end
    local score = calc_score(positions, str)
    return positions, score
end

-- unicode character 'EM SPACE'
local EM_SPACE = '\226\128\131'

local function split_basename(lines)
    return vim.tbl_map(function(line)
        line = line:gsub('^' .. os.getenv'HOME', '~')
        local is_uri = line:find('://') ~= nil
        if is_uri then
            return line .. EM_SPACE
        end
        local path, basename = line:match('^(.*)/(.-)$')
        if not path then
            return line .. EM_SPACE
        end
        return basename .. EM_SPACE .. path
    end, lines)
end

local function get_highlights_basename(result)
    if result:find('://') then  -- looks like a URI
        return {}
    end
    local starti, endi = result:find(EM_SPACE)
    if not starti then
        return {}
    end
    return {{col_start = endi, col_end = -1, hl_group = 'Comment'}}
end

local function on_complete_basename(action, results)
    local is_edit = action:match('edit') or action:match('split')
    for i, result in ipairs(results) do
        local found, _, basename, dir  = result:find'^([^:]+)\226\128\131(.*)$'
        if found then
            -- sometimes buffers just contain the basename for some reason
            dir = dir or vim.fn.getcwd()
            local path = dir .. '/' .. basename
            if i == #results or not is_edit then  -- open the file
                vim.cmd(action .. ' ' .. vim.fn.fnameescape(path))
            else  -- create a buffer
                local buf = vim.fn.bufnr(path, true)
                vim.bo[buf].buflisted = true
            end
        else
            -- Could be a URI, so treat the whole result as the filename
            if i == #results or not is_edit then
                vim.cmd(action .. ' ' .. vim.fn.fnameescape(result))
            else
                local buf = vim.fn.bufnr(result, true)
                vim.bo[buf].buflisted = true
            end
        end
    end
end

local function basename_cfg(t)
    return vim.tbl_deep_extend('keep', t, cfg{
        get_highlights = get_highlights_basename,
        matcher = match_basename,
        on_complete = on_complete_basename,
        scopes = '^([^:]+)\226\128\131(.*)$',
    })
end

local function oldfiles_source()
    return vim.tbl_filter(function(fname)
        return fname
            and vim.fn.empty(vim.fn.glob(vim.fn.fnameescape(fname))) == 0
            and vim.fn.isdirectory(fname) == 0
    end, vim.v.oldfiles)
end

local function oldfiles()
    ufind.open(split_basename(oldfiles_source()), basename_cfg{})
end

local function buffers()
    ufind.open(split_basename(require'ufind.source.buffers'()), basename_cfg{
        keymaps = {
            actions = {
                bd = '<C-d>',
            },
        },
    })
end

local function find()
    ufind.open_live('fd --color=always --fixed-strings --max-results=100 --type=file --', cfg{
        ansi = true,
    })
end

local function notes()
    local paths = vim.fn.systemlist('fd --type=file "" ' .. os.getenv'HOME' .. '/notes')
    ufind.open(split_basename(paths), basename_cfg{})
end

local function colorscheme_source()
    local schemes = vim.fn.getcompletion('', 'color')
    table.sort(schemes)

    local seen = {}
    local result = {}
    local function add(scheme)
        if scheme and scheme ~= '' and not seen[scheme] then
            seen[scheme] = true
            result[#result+1] = scheme
        end
    end

    add(vim.g.colors_name)
    for _, scheme in ipairs(schemes) do
        add(scheme)
    end
    return result
end

local failed_colorschemes = {}

local function apply_colorscheme(scheme, uf)
    if not scheme or scheme == '' or scheme == vim.g.colors_name then
        return
    end

    local ok, err = pcall(vim.cmd.colorscheme, scheme)
    if not ok then
        if not failed_colorschemes[scheme] then
            failed_colorschemes[scheme] = true
            vim.notify(err, vim.log.levels.WARN)
        end
        return
    end

    failed_colorschemes[scheme] = nil
    if uf then
        require'ufind.highlight'.setup(uf.ansi)
    end
end

local function preview_colorscheme(uf)
    if not vim.api.nvim_buf_is_valid(uf.result_buf) then
        return
    end

    local cursor = uf:get_cursor()
    local scheme = vim.api.nvim_buf_get_lines(
        uf.result_buf, cursor - 1, cursor, false)[1]
    if scheme == uf._config_last_colorscheme then
        return
    end

    uf._config_last_colorscheme = scheme
    apply_colorscheme(scheme, uf)
end

local function set_colorscheme_background(uf, scroll)
    local bg = scroll == 'scroll_left' and 'light' or 'dark'
    if vim.o.background == bg then
        return
    end

    vim.o.background = bg
    require'ufind.highlight'.setup(uf.ansi)
end

local function colorschemes()
    with_picker_hooks({
        on_select = preview_colorscheme,
        on_scroll = set_colorscheme_background,
    }, function()
        ufind.open(colorscheme_source(), cfg{
            keymaps = {
                scroll_left = '<Left>',
                scroll_right = '<Right>',
            },
            layout = {
                height = 0.45,
                width = 0.35,
            },
            on_complete = function(_, results)
                apply_colorscheme(results[#results])
            end,
        })
    end)
end

local function interactive_find()
    local function ls(path)
        local paths = {[1] = path .. '/..'}
        for name in vim.fs.dir(path) do
            table.insert(paths, path .. '/' .. name)
        end
        return paths
    end
    local function get_highlights(line)
        local col_start = line:find('/([^/]+)$')
        if col_start then
            return {
                {col_start = 0, col_end = col_start, hl_group = 'Comment'},
            }
        else
            return {}
        end
    end
    local function on_complete(action, lines)
        local line = assert(uv.fs_realpath(lines[1]))
        local info = uv.fs_stat(line)
        local is_dir = info and info.type == 'directory' or false
        if is_dir then
            vim.schedule(function()
                ufind.open(ls(line), cfg{
                    on_complete = on_complete,
                    get_highlights = get_highlights,
                })
            end)
        else
            vim.cmd(action .. ' ' .. vim.fn.fnameescape(line))
        end
    end
    ufind.open(ls(uv.cwd()), cfg{
        on_complete = on_complete,
        get_highlights = get_highlights,
    })
end

local function help_grep()
    ufind.open_live(function(query)
            return 'rg', {'--vimgrep', '--fixed-strings', '--color=ansi',
                '--glob=*.txt', '--', query, vim.env.VIMRUNTIME .. '/doc'}
        end,
        cfg{
            ansi = true,
            on_complete = function(cmd, lines)
                for i, line in ipairs(lines) do
                    local doc = line:match('[^:]+/([^:]+).txt:')
                    if doc then
                        vim.cmd('help ' .. doc)
                    else
                        print('not found:', doc)
                    end
                end
            end,
        })
end

map('n', '<space>b', buffers)
map('n', '<space>o', oldfiles)
map('n', '<space>f', find)
map('n', '<space>F', interactive_find)
map('n', '<space>n', notes)
map('n', '<space>c', colorschemes)
-- map('n', '<space>x', live_grep)
map('n', '<space>h', help_grep)

local function grep(query_str, query_tbl)
    local function cmd()
        local args = {'--vimgrep', '--fixed-strings', '--color=ansi', '--smart-case', '--'}
        if #query_tbl > 1 and util.exists(query_tbl[#query_tbl]) then
            -- seperate the path into its own argument
            local path = table.remove(query_tbl)
            table.insert(args, table.concat(query_tbl, ' '))
            table.insert(args, path)
        else
            table.insert(args, query_str)
        end
        return 'rg', args
    end
    ufind.open(cmd, cfg{
        ansi = true,
        scopes = '^([^:]-):%d+:%d+:(.*)$',
        on_complete = on_complete_grep,
        matcher = require'ufind.matcher.exact',
    })
end

com('Grep', function(o) grep(o.args, o.fargs) end, {nargs = '+'})
map('x', '<space>a', '\"vy:Grep <C-r>v<CR>')
map('n', '<space>a', ':<C-u>Grep ')
