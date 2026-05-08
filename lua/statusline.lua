local M = {}
local default_statusline = vim.o.statusline

local function hl(name, val)
    vim.api.nvim_set_hl(0, name, val)
end

local escape_statusline = function(s)
    return tostring(s):gsub('%%', '%%%%'):gsub('[\r\n]', ' ')
end

local component = function(hl, text)
    return '%#' .. hl .. '#' .. escape_statusline(text) .. '%*'
end

local git_diff_summary = function(bufnr)
    local summary = vim.b[bufnr].minidiff_summary
    if type(summary) ~= 'table' or summary.n_ranges == nil then return '' end

    local parts = {}
    if summary.add > 0 then
        table.insert(parts, component('StatusLineGitAdd', '+' .. summary.add))
    end
    if summary.change > 0 then
        table.insert(parts, component('StatusLineGitChange', '~' .. summary.change))
    end
    if summary.delete > 0 then
        table.insert(parts, component('StatusLineGitDelete', '-' .. summary.delete))
    end

    return table.concat(parts, ' ')
end

local function git_status()
    local winid = vim.g.statusline_winid
    if type(winid) ~= 'number' or not vim.api.nvim_win_is_valid(winid) then
        return ''
    end

    local bufnr = vim.api.nvim_win_get_buf(winid)
    local summary = vim.b[bufnr].minigit_summary
    if type(summary) ~= 'table' or summary.head_name == nil then return '' end

    local parts = {}

    -- Git branch
    if summary.head_name ~= nil then
        table.insert(parts, component('StatusLineGitBranch', '  ' .. summary.head_name))
    end

    -- Git status
    local diff = git_diff_summary(bufnr)
    if diff ~= '' then
        table.insert(parts, ' ' .. diff)
    end

    return table.concat(parts, ' ') .. ' '
end

local function session_status()
    local status = vim.fn['session#status']()
    if status == '' then return '' end
    return component('StatusLineSession', status) .. ' '
end

local diagnostic_levels = {
    {vim.diagnostic.severity.ERROR, 'DiagnosticUnderlineError'},
    {vim.diagnostic.severity.WARN,  'DiagnosticUnderlineWarn'},
    {vim.diagnostic.severity.INFO,  'DiagnosticUnderlineInfo'},
    {vim.diagnostic.severity.HINT,  'DiagnosticUnderlineHint'},
}

-- LSP diagnostics
vim.diagnostic.config({
    status = {format = function(counts)
        local parts = {}
        for _, level in ipairs(diagnostic_levels) do
            local count = counts[level[1]]
            if count ~= nil and count > 0 then
                table.insert(parts, component(level[2], count))
            end
        end
        return table.concat(parts, ' ')
    end},
})

M.statusline = function()
    local current_win = vim.g.statusline_winid == vim.fn.win_getid()
    return default_statusline
        .. (current_win and session_status() or '')
        .. (current_win and git_status() or '')
end

vim.opt.statusline = "%!v:lua.require'statusline'.statusline()"

M.setup_highlights = function()
    hl('StatusLineSession', {link = 'WarningMsg'})
    hl('StatusLineGitBranch', {fg_indexed = true, ctermfg = 13})
    hl('StatusLineGitBranchModified', {link = 'WarningMsg'})
    hl('StatusLineGitAdd', {link = 'Added'})
    hl('StatusLineGitChange', {link = 'Changed'})
    hl('StatusLineGitDelete', {link = 'Removed'})
end
M.setup_highlights()
aug'my/statusline'('ColorScheme', '*', M.setup_highlights)

-------------------------------------------------------------------------------

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
