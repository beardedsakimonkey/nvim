local au = aug'my/terminal'
local term = {
    buf = nil,
    win = nil,
}
local close_terminal

au('TermOpen', '*', function(args)
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
    map('n', '<Esc>', function()
        close_terminal()
    end, {buffer = args.buf})
    map('n', 'q', function()
        close_terminal()
    end, {buffer = args.buf})
    vim.cmd('startinsert')
end)

au('TermClose', '*', function(args)
    vim.cmd('bdelete! ' .. args.buf)
    if term.buf == args.buf then
        term.buf = nil
        term.win = nil
    end
end)

local function valid_buf(buf)
    return buf and vim.api.nvim_buf_is_valid(buf)
end

local function valid_win(win)
    return win and vim.api.nvim_win_is_valid(win)
end

local function find_terminal_buf()
    if valid_buf(term.buf) then
        return term.buf
    end

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if string.match(vim.api.nvim_buf_get_name(buf), '^term://') then
            term.buf = buf
            return buf
        end
    end
end

local function float_config()
    local width = math.min(math.floor(vim.o.columns * 0.9), vim.o.columns - 4)
    local height = math.min(math.floor(vim.o.lines * 0.8), vim.o.lines - 4)

    width = math.max(width, 20)
    height = math.max(height, 8)

    return {
        relative = 'editor',
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        border = 'rounded',
        style = 'minimal',
    }
end

function close_terminal()
    vim.cmd('stopinsert')
    vim.api.nvim_win_close(term.win, true)
    term.win = nil
end

local function open_terminal()
    local buf = find_terminal_buf()

    if buf then
        term.win = vim.api.nvim_open_win(buf, true, float_config())
    else
        term.buf = vim.api.nvim_create_buf(false, true)
        term.win = vim.api.nvim_open_win(term.buf, true, float_config())
        vim.cmd('terminal')
    end

    vim.cmd('startinsert')
end

-- Opens a singleton floating terminal or closes it if visible.
local function toggle_terminal()
    if valid_win(term.win) then
        close_terminal()
    else
        open_terminal()
    end
end

map('n', '<C-t>', toggle_terminal)
map('t', '<C-t>', toggle_terminal)
map('t', '<Esc>', [[<C-\><C-n>]])
map('t', '<C-h>', [[<C-\><C-n><C-w>h]])
map('t', '<C-j>', [[<C-\><C-n><C-w>j]])
map('t', '<C-k>', [[<C-\><C-n><C-w>k]])
map('t', '<C-l>', [[<C-\><C-n><C-w>l]])
