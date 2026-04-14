-- Color shorthands: $VIMRUNTIME/rgb.txt

vim.cmd 'hi clear'
vim.opt.background = 'light'
if vim.fn.exists('syntax_on') == 1 then
  vim.cmd 'syntax reset'
end
vim.g.colors_name = 'papyrus'

local function hl(name, val)
    vim.api.nvim_set_hl(0, name, val)
end

---@diagnostic disable: param-type-mismatch
hl('Cursor', {bg = 'Black', fg = 'White'})
hl('Normal', {bg = '#CDCABD', fg = 'Black'})
hl('NonText', {bg = '#C5C2B5', fg = 'none'})
hl('Visual', {bg = 'OliveDrab2', fg = 'fg'})
hl('Search', {bg = '#ffd787', fg = 'none'})
hl('IncSearch', {bg = '#ffc17a', fg = 'Black'})
hl('CurSearch', {link = 'IncSearch'})
hl('WarningMsg', {bg = 'none', bold = 1, fg = 'Red4'})
hl('ErrorMsg', {bg = 'IndianRed3', fg = 'White'})
hl('PreProc', {bg = 'none', fg = 'DeepPink4'})
hl('Comment', {bg = 'none', fg = 'Burlywood4'})
hl('Identifier', {bg = 'none', fg = 'Black'})
hl('Function', {fg = 'Black'})
hl('LineNr', {fg = 'Burlywood4'})
hl('Statement', {bg = 'none', fg = 'MidnightBlue'})
hl('Keyword', {bg = 'none', fg = 'MidnightBlue'})
hl('Type', {bg = 'none', fg = '#6D16BD'})
hl('Constant', {bg = 'none', fg = '#BD00BD'})
hl('Special', {bg = 'none', fg = 'DodgerBlue4'})
hl('String', {bg = 'none', fg = 'DarkGreen'})
hl('Whitespace', {fg = '#bab28f'})  -- trail listchar
hl('Directory', {bg = 'none', fg = 'Blue3'})
hl('SignColumn', {bg = '#c9c5b5', fg = 'none'})
hl('Todo', {bg = 'none', bold = 1, fg = 'Burlywood4'})
hl('MatchParen', {bg = 'PaleTurquoise', fg = 'none'})
hl('Title', {bold = 1, fg = 'DeepPink4'})
hl('Pmenu', {bg = '#e5daa5'})
hl('PmenuSel', {bg = 'LightGoldenrod3'})
hl('StatusLine', {bg = 'MistyRose4', fg = '#CDCABD'})
hl('StatusLineNC', {bg = '#b2a99d', fg = '#CDCABD'})
hl('TabLineFill', {bg = 'MistyRose4'})
hl('VertSplit', {bg = 'MistyRose4', fg = '#CDCABD'})
hl('CursorLine', {bg = '#ccc5b5'})
hl('Underlined', {fg = '#BD00BD', underline = 1})
hl('ColorColumn', {bg = '#ccb3a9'})
hl('CursorLineNr', {link = 'LineNr'})
hl('SpecialKey', {link = 'Directory'})

hl('DiffAdd', {bg = '#c6ddb1', fg = 'none'})
hl('DiffChange', {bg = '#dbd09d', fg = 'none'})
hl('DiffText', {bg = '#f4dc6e', fg = 'none'})
hl('DiffDelete', {bg = '#dda296', fg = 'none'})

hl('User1', {bg = 'MistyRose4', bold = 1, fg = 'AntiqueWhite2'})
hl('User2', {bg = 'OliveDrab2', fg = 'Black'})
hl('User3', {bg = 'MistyRose4', fg = '#CDCABD'})
hl('User4', {bg = 'MistyRose4', fg = 'Salmon'})
hl('User5', {bg = 'MistyRose4', fg = 'PaleGreen'})
hl('User6', {bg = 'MistyRose4', bold = 1, fg = '#CDCABD'})

hl('DiagnosticError', {fg = 'Red3'})
hl('DiagnosticWarn', {fg = 'Orange3'})
hl('DiagnosticInfo', {fg = 'Orange2'})
hl('DiagnosticHint', {fg = 'Orange2'})
hl('DiagnosticUnderlineError', {bg = '#dda296'})
hl('DiagnosticUnderlineWarn', {bg = '#e5daa5'})
hl('DiagnosticUnderlineInfo', {bg = '#dbd09d'})
hl('DiagnosticUnderlineHint', {bg = '#dbd09d'})
hl('DiagnosticSignError', {bg = '#c9c5b5', fg = 'Red3'})
hl('DiagnosticSignWarn', {bg = '#c9c5b5', fg = 'Orange3'})
hl('DiagnosticSignInfo', {bg = '#c9c5b5', fg = 'Orange2'})
hl('DiagnosticSignHint', {bg = '#c9c5b5', fg = 'Orange2'})
vim.cmd 'sign define DiagnosticSignError text=\226\151\143 texthl=DiagnosticSignError linehl= numhl='
vim.cmd 'sign define DiagnosticSignWarn  text=\226\151\143 texthl=DiagnosticSignWarn  linehl= numhl='
vim.cmd 'sign define DiagnosticSignInfo  text=\226\151\143 texthl=DiagnosticSignInfo  linehl= numhl='
vim.cmd 'sign define DiagnosticSignHint  text=\226\151\143 texthl=DiagnosticSignHint  linehl= numhl='

hl('UdirExecutable', {link = 'PreProc'})
hl('UfindMatch', {bg = 'none', bold = 1, fg = '#BD00BD'})
hl('UfindCursorLine', {link = 'DiffChange'})

hl('FennelSymbol', {fg = 'Black'})
hl('markdownH1', {link = 'Title'})
hl('markdownH2', {link = 'Statement'})
hl('markdownUrl', {fg = '#0645ad', underline = 1})
hl('markdownCode', {bg = '#dbd8ce'})
-- Custom '@' captures used in after/queries/*
hl('@text.title1', {link = 'markdownH1'})
hl('@text.title2', {link = 'markdownH2'})

hl('@constant.builtin', {link = 'Constant'})
hl('@function', {bold = 1, fg = 'Black'})
hl('@function.call', {fg = 'Blue3'})
hl('@keyword.operator', {link = 'PreProc'})
hl('@keyword.return', {link = 'PreProc'})
hl('TSURI', {link = 'markdownUrl'})
hl('TSLiteral', {link = 'markdownCode'})
-- hi(0, 'TSError', {bg ='#dda296'})
hl('rustCommentLineDoc', {link = 'Comment'})

hl('MiniOperatorsExchangeFrom', {bg = '#BD00BD', fg = 'White'})
