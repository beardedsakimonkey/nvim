local au = aug'my/hlsearch'

local function stop_highlight()
    if not vim.v.hlsearch or vim.api.nvim_get_mode().mode ~= 'n' then
        return
    end

    vim.schedule(function()
        if vim.v.hlsearch and vim.api.nvim_get_mode().mode == 'n' then
            vim.cmd.nohlsearch()
        end
    end)
end

local function start_highlight()
    if not vim.v.hlsearch then
        return
    end

    local wininfo = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
    local lnum = vim.api.nvim_win_get_cursor(0)[1]
    local scrolloff = vim.o.scrolloff

    -- bail out if cursor is at top/bottom of window
    if lnum == wininfo.botline - scrolloff or lnum == wininfo.topline + scrolloff then
        return
    end

    local ok, pos = pcall(function()
        return vim.fn.match(vim.api.nvim_get_current_line(), vim.fn.getreg('/'), vim.fn.col('.') - 1) + 1
    end)

    if not ok or pos ~= vim.fn.col('.') then
        stop_highlight()
    end
end

au('CursorMoved', '*', start_highlight)
au('InsertEnter', '*', stop_highlight)
