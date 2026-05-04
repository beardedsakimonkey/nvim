local M = {}

M.statusline = function()
    local current_win = vim.g.statusline_winid == vim.fn.win_getid()
    local buf = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
    local diag = vim.diagnostic.status(buf)
    local progress = package.loaded['vim.ui'] and vim.ui.progress_status() or ''
    return "%1*%{!&modifiable ? '  X ' : &ro ? '  RO ' : ''}"
        .. "%2*%{&modified ? '  + ' : ''}%* %7*"
        .. "%*%{&bt=='nofile' ? '[Nofile]' : expand('%:t')}%* "
        .. "%{&ff!='unix' ? '[' . &ff . '] ' : ''}"
        .. "%{&fenc!='utf-8' && &fenc != '' ? '[' . &fenc . '] ' : ''}"
        .. (diag ~= '' and diag .. ' ' or '')
        .. '%='
        .. "%{&busy ? '◐ ' : ''}"
        .. (progress ~= '' and progress .. ' ' or '')
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
