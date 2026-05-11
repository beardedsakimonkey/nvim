local dirtree = require'dirtree'

local function setup_highlights()
    vim.api.nvim_set_hl(0, 'DirtreeDirectory', {link = 'MoreMsg', update = true})
end

dirtree.config = vim.tbl_deep_extend('force', dirtree.config, {
    keymaps = {
        r = "<Cmd>lua require'dirtree.core'.move()<CR>",
        H = {"<Cmd>lua require'dirtree.core'.help()<CR>", desc="Open Help"},
        ['+'] = "<Cmd>lua require'dirtree.core'.create()<CR>",
        gh = "<Cmd>lua require'dirtree.core'.toggle_hidden_files()<CR>",
    },
})

setup_highlights()
aug'my/udir'('ColorScheme', '*', setup_highlights)

map('n', '-', '<Cmd>Dirtree<CR>')
