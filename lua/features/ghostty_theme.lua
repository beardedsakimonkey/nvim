local M = {}

local ghostty_config = vim.fn.expand'~/.config/ghostty/config'
local last_theme

local schemes = {
    ['one half dark'] = 'onehalfdark',
    ['monokai classic'] = 'unokai',
    ['sonokai'] = 'sonokai',
}

local function read(path)
    local fd = io.open(path, 'r')
    if fd == nil then return nil end
    local text = fd:read'*a'
    fd:close()
    return text
end

local function trim(s)
    return s:match'^%s*(.-)%s*$'
end

local function conf_value(text, key)
    local pattern = '^%s*' .. key:gsub('%-', '%%-') .. '%s*=%s*(.-)%s*$'
    for line in text:gmatch'[^\r\n]+' do
        local value = line:match(pattern)
        if value ~= nil and not line:match'^%s*#' then
            return trim(value)
        end
    end
end

local function active_ghostty_theme()
    local text = read(ghostty_config)
    if text == nil then return nil end

    local include = conf_value(text, 'config-file')
    if include ~= nil and not include:match'^/' then
        include = vim.fs.dirname(ghostty_config) .. '/' .. include
    end

    if include ~= nil then
        local included = read(include)
        if included ~= nil then
            return conf_value(included, 'theme')
        end
    end

    return conf_value(text, 'theme')
end

function M.apply()
    local theme = active_ghostty_theme()
    if theme == nil or theme == last_theme then return end

    local scheme = schemes[theme:lower()]
    if scheme == nil then return end

    last_theme = theme
    vim.cmd.colorscheme(scheme)
end

local au = aug'my/ghostty-theme'
au('BufWritePost', {'*/.config/ghostty/config'}, M.apply)

return M
