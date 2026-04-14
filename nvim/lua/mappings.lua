-- backslash is the default <leader>
vim.g.mapleader = '\\'

-- Adapted from lacygoill's vimrc
local function zoom_toggle()
    if vim.fn.winnr('$') ~= 1 then
        if vim.t.zoom_restore then
            vim.cmd 'exe t:zoom_restore'
            vim.cmd 'unlet t:zoom_restore'
        else
            vim.t.zoom_restore = vim.fn.winrestcmd()
            vim.cmd 'wincmd |'
            vim.cmd 'wincmd _'
        end
    end
end

-- Adapted from lacygoill's vimrc
local function repeat_last_edit()
    local changed = vim.fn.getreg('"', 1, 1)
    if changed then
        -- Escape backslashes
        local changed_esc = vim.tbl_map(function(c)
            return vim.fn.escape(c, '\\')
        end, changed)
        local pat = table.concat(changed_esc, '\\n')
        -- Put the last changed text inside the search register, so that we can
        -- refer to it with the text-object `gn`
        vim.fn.setreg('/', ('\\V' .. pat), 'c')
        vim.cmd 'exe "norm! cgn\\<c-@>"'
    end
end

-- Adapted from lacygoill's vimrc
local function navigate(dir)
    local prev_win_same_dir -- previous window in same direction
    local cnr = vim.fn.winnr()
    local pnr = vim.fn.winnr('#')
    if dir == 'h' then
        local leftedge_cur_win = vim.fn.win_screenpos(cnr)[2]
        local rightedge_prev_win = vim.fn.win_screenpos(pnr)[2] + vim.fn.winwidth(pnr) - 1
        prev_win_same_dir =  (leftedge_cur_win - 1) == (rightedge_prev_win + 1)
    elseif dir == 'l' then
        local leftedge_prev_win = vim.fn.win_screenpos(pnr)[2]
        local rightedge_cur_win = vim.fn.win_screenpos(cnr)[2] + vim.fn.winwidth(cnr) - 1
        prev_win_same_dir = (leftedge_prev_win - 1) == (rightedge_cur_win + 1)
    elseif dir == 'j' then
        local topedge_prev_win = vim.fn.win_screenpos(pnr)[1]
        local bottomedge_cur_win = vim.fn.win_screenpos(cnr)[1] + vim.fn.winheight(cnr) - 1
        prev_win_same_dir = (topedge_prev_win - 1) == (bottomedge_cur_win + 1)
    elseif dir == 'k' then
        local topedge_cur_win = vim.fn.win_screenpos(cnr)[1]
        local bottomedge_prev_win = vim.fn.win_screenpos(pnr)[1] + vim.fn.winheight(pnr) - 1
        prev_win_same_dir = (topedge_cur_win - 1) == (bottomedge_prev_win + 1)
    end
    vim.cmd('try | wincmd ' .. (prev_win_same_dir and 'p' or dir) .. ' | catch | entry')
end

local function rename()
    local cword = vim.fn.expand('<cword>')
    vim.fn.setreg('/', ("\\<" .. cword .. "\\>"), 'c')
    local keys = vim.api.nvim_replace_termcodes(':%s///gc<left><left><left>',
        true, false, true)
    vim.api.nvim_feedkeys(keys, 'n', false)
end

local function yank_doc(exp)
    local txt = vim.fn.expand(exp)
    vim.fn.setreg('"', txt, 'c')
    vim.fn.setreg('+', txt, 'c')
end

-- Enhanced defaults
map('n', 'j', 'gj')
map('n', 'k', 'gk')
map('n', '<Down>', 'gj')
map('n', '<Up>', 'gk')
map('', '<C-g>', 'g<C-g>')
map('n', '<', '<<')
map('n', '>', '>>')
map('x', '<', '<gv')
map('x', '>', '>gv')
map('n', 's', '"_s')
map('n', 'p', "getreg(v:register) =~# \"\\n\" ? \"pmv=g']g`v\" : 'p'", {expr = true})
map('n', 'P', "getreg(v:register) =~# \"\\n\" ? \"Pmv=g']g`v\" : 'P'", {expr = true})
map('x', 'p', "'\"_c<C-r>'.v:register.'<Esc>'", {expr = true})
map('x', 'gp', 'p') -- paste and yank (useful for exchanging)
map('n', '`', 'g`')
map('n', "'", "g'")
map('n', 'n', '<Cmd>keepj norm! nzzzv<CR>', {silent = true})
map('n', 'N', '<Cmd>keepj norm! Nzzzv<CR>', {silent = true})
map('n', '*', '*zzzv', {silent = true})
map('n', '#', '#zzzv', {silent = true})
map('n', 'g*', 'g*zzzv', {silent = true})
map('n', 'g#', 'g#zzzv', {silent = true})
map('n', "g'", 'g,')
map('n', '<PageUp>', '<PageUp>:keepj norm! H<CR>', {silent = true})
map('n', '<PageDown>', '<PageDown>:keepj norm! L<CR>', {silent = true})
map('n', '/', '/\\V')
map('x', '/', function() vim.api.nvim_input('/\\%V') end) -- search in visual selection

-- Rearrange some default mappings
map({'n', 'x'}, ';', ':')
map({'n', 'x'}, ':', ';')
map('n', '`', "'")
map('n', "'", '`')
map('', 'H', '^')
map('', 'L', '$')
map('', '(', '<Cmd>keepj norm! H<CR>', {silent = true})
map('', ')', '<Cmd>keepj norm! L<CR>', {silent = true})
map('n', '<Home>', '<Cmd>keepj norm! gg<CR>', {silent = true})
map('n', '<End>', '<Cmd>keepj norm! G<CR>', {silent = true})
map('n', '<C-s>', '<C-a>', {silent = true})
map('', '<tab>', '<Cmd>keepj norm! %<CR>', {silent = true})
map('n', '<C-p>', '<Tab>')
map('n', '<C-l>', function() navigate'l' end, {silent = true})
map('n', '<C-h>', function() navigate'h' end, {silent = true})
map('n', '<C-j>', function() navigate'j' end, {silent = true})
map('n', '<C-k>', function() navigate'k' end, {silent = true})
map('n', 'zk', 'zc', {silent = true})
map('n', 'zK', 'zC', {silent = true})
map('n', 'zj', 'zo', {silent = true})
map('n', 'zJ', 'zO', {silent = true})

-- Insert mode
map('i', '<C-j>', '<C-n>')
map('i', '<C-k>', '<C-p>')
map('i', '<C-l>', '<C-n>')


-- Miscellaneous
map('n', 'cn', 'cgn', {silent = true})
map({'n', 'x'}, 'Z', 'zzzH')
map('n', 'Q', '@q')
map('n', '<A-LeftMouse>', '<nop>')
map('n', '<CR>', '<Cmd>w<CR>', {silent = true})
map('', '<C-q>', '<Cmd>q<CR>', {silent = true})
map('n', '<space>l', '<Cmd>vsplit<CR>', {silent = true})
map('n', '<space>j', '<Cmd>split<CR>', {silent = true})
map('n', '<space>t', '<Cmd>tabedit<CR>', {silent = true})
map('', '<Space>d', '<Cmd>call Kwbd(1)<CR>', {silent = true})
map('', '<Space>q', '<Cmd>b#<CR>', {silent = true})
map('n', 'g>', '<Cmd>40messages<CR>', {silent = true})
map('n', 'gi', 'g`^')  -- go to last insert
map('n', 'g.', 'g`.')  -- go to last change
map('n', 'gs', 'g`[vg`]')  -- select last changed/yanked text
map('n', 'gS', "g'[Vg']")
map('n', '<space>z', zoom_toggle, {silent = true})
map('x', '.', ':norm! .<CR>', {silent = true})
map('n', '<space>.', repeat_last_edit)
map('x', '<space>y', '"*y', {silent = true})

-- Command mode
map('c', '<C-p>', '<Up>')
map('c', '<C-n>', '<Down>')
map('c', '<C-j>', '<C-g>')
map('c', '<C-k>', '<C-t>')
map('c', '<C-a>', '<Home>')

-- Keepjumps
map('n', 'M', '<Cmd>keepj norm! M<CR>', {silent = true})
map('n', '{', '<Cmd>keepj norm! {<CR>', {silent = true})
map('n', '}', '<Cmd>keepj norm! }<CR>', {silent = true})
map('n', 'gg', '<Cmd>keepj norm! gg<CR>', {silent = true})
map('n', 'G', '<Cmd>keepj norm! G<CR>', {silent = true})

-- Search & substitute
-- NOTE: Doesn't support multiline selection. Adapted from lacygoill's vimrc.
map("x", "*", "\"vy:let @/='\\<<c-r>v\\>'<CR>nzzzv", {silent = true})
map("x", "#", "\"vy:let @/='\\<<c-r>v\\>'<CR>Nzzzv", {silent = true})
map("x", "g*", "\"vy:let @/='<c-r>v'<CR>nzzzv", {silent = true})
map("x", "g#", "\"vy:let @/='<c-r>v'<CR>Nzzzv", {silent = true})
map("n", "g/", ":<c-u>let @/='\\<<c-r>=expand(\"<cword>\")<CR>\\>'<CR>:set hls<CR>", {silent = true})
map("x", "g/", "\"vy:let @/='<c-r>v'<Bar>set hls<CR>")
map({"n", "x"}, "<RightMouse>", "<leftmouse>:<c-u>let @/='\\<<c-r>=expand(\"<cword>\")<CR>\\>'<CR>:set hls<CR>", {silent = true})
map("n", "<Space>s", "ms:<C-u>%s///g<left><left>")
map("x", "<space>s", "\"vy:let @/='<c-r>v'<CR>:<C-u>%s///g<left><left>")
map('n', 'R', rename)
map('n', 'gr', 'R')

-- Alt
map('!', '<A-h>', '<Left>')
map('!', '<A-l>', '<Right>')
map('!', '<A-j>', '<C-Left>')
map('!', '<A-k>', '<C-Right>')
map('n', '<A-l>', '<C-w>L')
map('n', '<A-h>', '<C-w>H')
map('n', '<A-j>', '<C-w>J')
map('n', '<A-k>', '<C-w>K')

-- Bracket
map('n', ']b', '<Cmd>bnext<CR>', {silent = true})
map('n', '[b', '<Cmd>bprev<CR>', {silent = true})
map('n', '[t', '<Cmd>tabprev<CR>', {silent = true})
map('n', ']t', '<Cmd>tabnext<CR>', {silent = true})
map('n', ']T', '<Cmd>+tabmove<CR>', {silent = true})
map('n', '[T', '<Cmd>-tabmove<CR>', {silent = true})
map('n', ']q', ':<C-u><C-r>=v:count1<CR>cnext<CR>zz', {silent = true})
map('n', '[q', ':<C-u><C-r>=v:count1<CR>cprev<CR>zz', {silent = true})
map('n', ']Q', '<Cmd>cnfile<CR>zz', {silent = true})
map('n', '[Q', '<Cmd>cpfile<CR>zz', {silent = true})
map('n', ']l', ':<C-u><c-r>=v:count1<CR>lnext<CR>zz', {silent = true})
map('n', '[l', ':<C-u><c-r>=v:count1<CR>lprev<CR>zz', {silent = true})
map('n', ']L', '<Cmd>lnfile<CR>zz', {silent = true})
map('n', '[L', '<Cmd>lpfile<CR>zz', {silent = true})
-- Adapted from lacygoill's vimrc.
map('', ']n', '/\\v^[<\\|=>]{7}<CR>zvzz', {silent = true})
map('', '[n', '?\\v^[<\\|=>]{7}<CR>zvzz', {silent = true})
local function move_line(dir)
    vim.cmd 'keepj norm! mv'
    vim.cmd('move ' .. (dir == 'up' and '--' or '+') .. vim.v.count1)
    vim.cmd 'keepj norm! =`v'
end
map('n', '[d', function() move_line'up' end)
map('n', ']d', function() move_line'down' end)

-- Bookmarks
map('n', ':V', '<Cmd>e ~/.config/nvim/<CR>', {silent = true})
map('n', ':L', '<Cmd>e ~/.config/nvim/lua/<CR>', {silent = true})
map('n', ':C', '<Cmd>e ~/.config/nvim/lua/config/<CR>', {silent = true})
map('n', ':A', '<Cmd>e ~/.config/nvim/after/ftplugin/<CR>', {silent = true})
map('n', ':P', '<Cmd>e ~/.local/share/nvim/site/pack/paqs/start/<CR>', {silent = true})
map('n', ':R', '<Cmd>e $VIMRUNTIME<CR>', {silent = true})
map('n', ':Z', '<Cmd>e ~/.zshrc<CR>', {silent = true})
map('n', ':N', '<Cmd>e ~/notes/_notes.md<CR>', {silent = true})
map('n', ':T', '<Cmd>e ~/notes/_todo.md<CR>', {silent = true})
map('n', ':X', '<Cmd>e ~/.config/tmux/tmux.conf<CR>', {silent = true})
map('n', ':U', '<Cmd>e ~/Library/Application\\ Support/Firefox/Profiles/2a6723nr.default-release/user.js<CR>', {silent = true})

-- Text objects
map({'x', 'o'}, 'il', '<Cmd>norm! g_v^<CR>', {silent = true})
map({'x', 'o'}, 'al', '<Cmd>norm! $v0<CR>', {silent = true})
map('x', 'id', '<Cmd>norm! G$Vgg0<CR>', {silent = true})
map('o', 'id', '<Cmd>norm! GVgg<CR>', {silent = true})

-- File name
map('i', '<C-o>', '<c-r>=expand("%:t:r:r:r")<CR>', {silent = true})
map('c', '<C-o>', '<c-r>=expand("%:t:r:r:r")<CR>', {silent = true})
map('n', 'yo', function() yank_doc('%:t:r:r:r') end, {silent = true})
map('n', 'yO', function() yank_doc('%:p') end, {silent = true})

-- Toggle options
map('n', 'gon', '<Cmd>set number!<CR>', {silent = true})
map('n', 'goc', '<Cmd>set cursorline!<CR>', {silent = true})
map('n', 'gol', '<Cmd>set list!<CR>', {silent = true})
map('n', 'gow', '<Cmd>set wrap!<Bar>set wrap?<CR>')
map('n', 'goi', '<Cmd>set ignorecase!<Bar>set ignorecase?<CR>')

-- Diagnostics
map('n', 'ge', '<Cmd>lua vim.diagnostic.open_float()<CR>', {silent = true})
map('n', '[e', '<Cmd>lua vim.diagnostic.goto_prev()<CR>', {silent = true})
map('n', ']e', '<Cmd>lua vim.diagnostic.goto_next()<CR>', {silent = true})
map('n', 'gl', '<Cmd>lua vim.diagnostic.setloclist()<CR>', {silent = true})

-- Avoid typo
vim.cmd 'cnoreabbrev ~? ~/'
vim.cmd[[cnoreabbrev <expr> man getcmdtype() is# ":" && getcmdpos() == 4 ? 'vert Man' : 'man']]
