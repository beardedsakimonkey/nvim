local M = {}
local default_statusline = vim.o.statusline

local function set_hl(name, val)
    vim.api.nvim_set_hl(0, name, val)
end

local escape_statusline = function(s)
    return tostring(s):gsub('%%', '%%%%'):gsub('[\r\n]', ' ')
end

local component = function(hl_name, text)
    return '%#' .. hl_name .. '#' .. escape_statusline(text) .. '%*'
end

local function set_lsp_status(bufnr, client_id, active)
    if type(client_id) ~= 'number' or not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end

    local clients = vim.b[bufnr].statusline_lsp_clients
    if type(clients) ~= 'table' then
        clients = {}
        vim.b[bufnr].statusline_lsp_clients = clients
    end

    local was_active = next(clients) ~= nil
    if active then
        clients[client_id] = true
    else
        clients[client_id] = nil
    end

    local is_active = next(clients) ~= nil
    vim.b[bufnr].statusline_lsp_active = is_active
    if is_active ~= was_active then
        vim.cmd('redrawstatus')
    end
end

local function update_lsp_diagnostic_status(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end

    local counts = vim.diagnostic.count(bufnr)
    local previous = vim.b[bufnr].statusline_lsp_severity
    local severity = nil
    if (counts[vim.diagnostic.severity.ERROR] or 0) > 0 then
        severity = vim.diagnostic.severity.ERROR
    elseif (counts[vim.diagnostic.severity.WARN] or 0) > 0 then
        severity = vim.diagnostic.severity.WARN
    end

    vim.b[bufnr].statusline_lsp_severity = severity
    if severity ~= previous then
        vim.cmd('redrawstatus')
    end
end

local function lsp_status(bufnr)
    if not vim.b[bufnr].statusline_lsp_active then return '' end
    local severity = vim.b[bufnr].statusline_lsp_severity
    if severity and severity <= vim.diagnostic.severity.WARN then
        return component('DiagnosticError', '✘')
    end
    return component('DiagnosticOk', '✔')
end

local function git_diff_summary(bufnr)
    local summary = vim.b[bufnr].minidiff_summary
    if type(summary) ~= 'table' or summary.n_ranges == nil then return '' end

    local parts = {}
    if summary.add > 0    then table.insert(parts, component('StatusLineGitAdd',    '+' .. summary.add)) end
    if summary.change > 0 then table.insert(parts, component('StatusLineGitChange', '~' .. summary.change)) end
    if summary.delete > 0 then table.insert(parts, component('StatusLineGitDelete', '-' .. summary.delete)) end

    return table.concat(parts, ' ')
end

local function git_status(winid, bufnr)
    if type(winid) ~= 'number' or not vim.api.nvim_win_is_valid(winid) then
        return ''
    end

    local summary = vim.b[bufnr].minigit_summary
    if type(summary) ~= 'table' or summary.head_name == nil then return '' end

    local parts = {}

    -- Git status
    local diff = git_diff_summary(bufnr)
    if diff ~= '' then
        table.insert(parts, ' ' .. diff)
    end

    -- Git branch
    if summary.head_name ~= nil then
        table.insert(parts, component('StatusLineGitBranch', '  ' .. summary.head_name))
    end

    return table.concat(parts, ' ') .. ' '
end

local function session_status()
    local status = vim.fn['session#status']()
    if status == '' then return '' end
    -- only show the first character
    local char = vim.fn.strcharpart(status, 0, 1, true)
    return component('StatusLineSession', char) .. ' '
end

local diagnostic_levels = {
    {vim.diagnostic.severity.ERROR, 'DiagnosticUnderlineError'},
    {vim.diagnostic.severity.WARN,  'DiagnosticUnderlineWarn'},
    -- {vim.diagnostic.severity.INFO,  'DiagnosticTextInfo'},
    -- {vim.diagnostic.severity.HINT,  'DiagnosticTextHint'},
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
    local winid = vim.g.statusline_winid
    local is_current_win = winid == vim.fn.win_getid()
    if is_current_win then
        local bufnr = vim.api.nvim_win_get_buf(winid)
        return default_statusline
            .. lsp_status(bufnr)
            -- .. git_status(winid, bufnr)
            .. session_status()
    end
    return default_statusline
end

vim.opt.statusline = "%!v:lua.require'statusline'.statusline()"

local function setup_highlights()
    set_hl('StatusLineSession',   {fg_indexed = true, ctermfg = 13})
    set_hl('StatusLineGitAdd',    {link = 'Added'})
    set_hl('StatusLineGitChange', {link = 'Changed'})
    set_hl('StatusLineGitDelete', {link = 'Removed'})
end

local au = aug'my/statusline'
au('ColorScheme', '*', setup_highlights)


au('LspAttach', '*', function(args)
    set_lsp_status(args.buf, args.data.client_id, true)
    update_lsp_diagnostic_status(args.buf)
end)
au('LspDetach', '*', function(args) set_lsp_status(args.buf, args.data.client_id, false) end)
au('DiagnosticChanged', '*', function(args) update_lsp_diagnostic_status(args.buf) end)

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
