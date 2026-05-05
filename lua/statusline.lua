local M = {}
local default_statusline = vim.o.statusline

local escape_statusline = function(s)
    return s:gsub('%%', '%%%%')
end

M.git_status = function()
    local winid = vim.g.statusline_winid
    if type(winid) ~= 'number' or not vim.api.nvim_win_is_valid(winid) then
        return ''
    end

    local bufnr = vim.api.nvim_win_get_buf(winid)
    local summary = vim.b[bufnr].minigit_summary_string
    if summary == nil or summary == '' then return '' end

    return escape_statusline(summary) .. ' '
end

M.statusline = function()
    local current_win = vim.g.statusline_winid == vim.fn.win_getid()
    return "" --"%#DiffAdd#%{&modified ? '  + ' : ''}%* "
        .. default_statusline
        .. M.git_status()
        .. (current_win and '%{session#status()} ' or '')
end

vim.opt.statusline = "%!v:lua.require'statusline'.statusline()"

M.tabline = function()
    local s = ''
    for i = 1, vim.fn.tabpagenr('$') do
        s = s
            .. (i == vim.fn.tabpagenr() and '%#TabLineSel#' or '%#TabLine#')
            .. '%' .. i
            .. "T %{v:lua.require'statusline'.tablabel(" .. i .. ')}'
    end
    return s .. '%#TabLineFill#%T'
end

M.tablabel = function(n)
    local buflist = vim.fn.tabpagebuflist(n)
    local modified = ''
    for _, b in ipairs(buflist) do
        if modified ~= '' then break end
        if vim.bo[b].modified then
            modified = '+ '
        end
    end
    local name = vim.fn.fnamemodify(
        vim.fn.bufname(buflist[vim.fn.tabpagewinnr(n)]), ':t:s/^$/[No Name]/')
    return modified .. name .. ' '
end

vim.opt.tabline = "%!v:lua.require'statusline'.tabline()"

return M
