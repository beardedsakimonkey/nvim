local M = {}

function M.exists(path)
    -- Passing '' as the mode corresponds to access(2)'s F_OK
    return vim.loop.fs_access(path, '') == true
end

M.FF_PROFILE = '/Users/tim/Library/Application Support/Firefox/Profiles/2a6723nr.default-release/'

function M.memo(fn)
    local v
    return function(...)
        if v then return v end
        v = fn(...)
        return v
    end
end

-- Merges two sequential tables
function M.tbl_append(t1, t2)
    local res = {}
    for _, v in ipairs(t1) do
        table.insert(res, v)
    end
    for _, v in ipairs(t2) do
        table.insert(res, v)
    end
    return res
end

return M
