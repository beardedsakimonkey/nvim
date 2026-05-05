local au = aug'my/terminal'

au('TermOpen', '*', function(args)
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
    vim.cmd('startinsert')
end)

au('TermClose', '*', function(args)
    vim.cmd('bdelete! ' .. args.buf)
end)

-- Opens a terminal in a split or switches to an existing one
local function toggle_terminal()
  local term_buf = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if string.match(vim.api.nvim_buf_get_name(buf), '^term://') then
      term_buf = buf
      break
    end
  end
  if term_buf then
    vim.cmd('vert sbuffer ' .. term_buf)
  else
    vim.cmd('vsplit | terminal')
  end
end

map('n', '<C-t>', toggle_terminal)
map('t', '<Esc>', [[<C-\><C-n>]])
map('t', '<C-h>', [[<C-\><C-n><C-w>h]])
map('t', '<C-j>', [[<C-\><C-n><C-w>j]])
map('t', '<C-k>', [[<C-\><C-n><C-w>k]])
map('t', '<C-l>', [[<C-\><C-n><C-w>l]])
