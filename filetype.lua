vim.filetype.add{
    extension = {
        jsx = 'javascriptreact',
        flow = 'javascript',
        vert = 'glsl',
        frag = 'glsl',
        s = 'nasm',
    },
    filename = {
        ['tmux.conf'] = 'tmux',
        ['.fasdrc'] = 'bash',
        ['rtorrent.rc'] = 'dosini',
        ['.luacheckrc'] = 'lua',
    },
    pattern = {
        ['/zsh/functions/[^/]-$'] = 'zsh',
        ['res?i?$'] = 'ocaml',
    },
}
