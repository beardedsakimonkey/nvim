if vim.g.loaded_wildignorecase then
  return
end
vim.g.loaded_wildignorecase = true

vim.o.wildcharm = vim.fn.char2nr('\t')

local saved_wildignorecase

local function cmdline_tab()
  if vim.fn.getcmdtype() == ':' then
    local cmdline = vim.fn.getcmdline()
    local pos = vim.fn.getcmdpos()
    local token = vim.fn.matchstr(cmdline:sub(1, pos - 1), [[[^ /]\+$]])
    vim.o.wildignorecase = token:find('[A-Z]') == nil
  end

  return vim.api.nvim_replace_termcodes('<Tab>', true, false, true)
end

vim.keymap.set('c', '<Tab>', cmdline_tab, { expr = true, silent = true })

local group = vim.api.nvim_create_augroup('wildignorecase', { clear = true })
vim.api.nvim_create_autocmd('CmdlineEnter', {
  group = group,
  callback = function()
    saved_wildignorecase = vim.o.wildignorecase
  end,
})
vim.api.nvim_create_autocmd('CmdlineLeave', {
  group = group,
  callback = function()
    if saved_wildignorecase ~= nil then
      vim.o.wildignorecase = saved_wildignorecase
    end
  end,
})
