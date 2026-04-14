local function get_char()
    local ok, char_num = pcall(vim.fn.getchar)
    -- Return nil if error (e.g. <C-c>) or for control characters
    if not ok or type(char_num) ~= 'number' or char_num < 32 then
        return nil
    end
    return vim.fn.nr2char(char_num)
end

local function gen_hash(key)
    local win = vim.api.nvim_get_current_win()
    local cursor = vim.api.nvim_win_get_cursor(0)
    -- Note: ignore `key`s casing so that we can change direction
    return ('%s|%s|%s:%s'):format(key:lower(), win, cursor[1], cursor[2])
end

local prev_hash

-- Supports repeating the last search with f/t/F/T instead of ;/,
local function ft(key)
    local hash = gen_hash(key)
    local is_forward = key == 'f' or key == 't'
    if hash == prev_hash then
        vim.cmd('normal! ' .. (is_forward and ';' or ','))
    else
        local char = get_char()
        if not char then
            return
        end
        vim.cmd('normal! ' .. key .. char)
    end
    prev_hash = gen_hash(key)
end

vim.keymap.set({'n', 'x'}, 'f', function() ft('f') end)
vim.keymap.set({'n', 'x'}, 't', function() ft('t') end)
vim.keymap.set({'n', 'x'}, 'F', function() ft('F') end)
vim.keymap.set({'n', 'x'}, 'T', function() ft('T') end)
