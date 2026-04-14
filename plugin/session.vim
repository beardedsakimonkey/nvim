"
" adapted from https://github.com/lacygoill/vim-session
"

if exists('g:loaded_session')
    finish
endif
let g:loaded_session = 1

augroup my_session | au!
    au StdInReadPost * let s:read_stdin = 1
    au VimEnter * ++nested call s:load_session_on_vimenter()
    au BufWinEnter * exe s:track(0)
    au TabClosed * call timer_start(0, { -> execute('exe ' .. string(function('s:track', [0])) .. '()') })
    au VimLeavePre * exe s:track(1)
        \ | if get(g:, 'MY_LAST_SESSION', '') isnot# ''
        \ |     call writefile([g:MY_LAST_SESSION], $HOME..'/.local/share/nvim/session/last')
        \ | endif
augroup END

com -bar -nargs=? -complete=custom,s:suggest_sessions SClose  exe s:close()
com -bar -nargs=? -complete=custom,s:suggest_sessions SDelete exe s:delete(<q-args>)
com -bar -nargs=1 -complete=custom,s:suggest_sessions SRename exe s:rename(<q-args>)
com -bar -nargs=? -complete=custom,s:suggest_sessions SLoad  exe s:load(<q-args>)
com -bar -bang -nargs=? -complete=custom,s:suggest_sessions STrack exe s:handle_session(<bang>0, <q-args>)

fu s:close() abort
    if !exists('g:my_session') | return '' | endif
    sil STrack
    sil tabonly | sil only | enew
    call s:rename_tmux_window('vim')
    return ''
endfu

fu s:delete(session) abort
    if a:session is# '#'
        if exists('g:MY_PENULTIMATE_SESSION')
            let session_to_delete = g:MY_PENULTIMATE_SESSION
        else
            return 'echoerr "No alternate session to delete"'
        endif
    else
        let session_to_delete = a:session is# ''
            \ ? get(g:, 'my_session', 'MY_LAST_SESSION')
            \ : fnamemodify(s:SESSION_DIR..'/'..a:session..'.vim', ':p')
    endif

    if session_to_delete is# get(g:, 'MY_PENULTIMATE_SESSION', '')
        unlet! g:MY_PENULTIMATE_SESSION
    elseif session_to_delete is# get(g:, 'my_session', '')
        if exists('g:MY_PENULTIMATE_SESSION')
            SLoad#
            unlet! g:MY_PENULTIMATE_SESSION
        else
            SClose
        endif
    endif

    if delete(session_to_delete)
        return 'echoerr '..string('Failed to delete '..session_to_delete)
    endif
    return 'echo '..string(session_to_delete..' has been deleted')
endfu

fu s:handle_session(bang, file) abort
    let s:bang = a:bang
    let s:file = a:file
    let s:last_used_session = get(g:, 'my_session', v:this_session)

    try
        if s:should_pause_session()
            return s:session_pause()
        elseif s:should_delete_session()
            return s:session_delete()
        endif

        let s:file = s:where_do_we_save()
        if s:file is# '' | return '' | endif

        if !s:bang && a:file isnot# '' && filereadable(s:file)
            return 'mksession '..fnameescape(s:file)
        endif

        let g:my_session = s:file

        let error = s:track(0)
        if error is# ''
            echo 'Tracking session in '..fnamemodify(s:file, ':~:.')
            call s:rename_tmux_window(s:file)
            return ''
        else
            return error
        endif

    finally
        redrawt
        redraws!
        unlet! s:bang s:file s:last_used_session
    endtry
endfu

fu s:load(session_file) abort
    let session_file = a:session_file is# ''
           \ ?     get(g:, 'MY_LAST_SESSION', '')
           \ : a:session_file is# '#'
           \ ?     get(g:, 'MY_PENULTIMATE_SESSION', '')
           \ : a:session_file =~# '/'
           \ ?     fnamemodify(a:session_file, ':p')
           \ :     s:SESSION_DIR..'/'..a:session_file..'.vim'

    let session_file = resolve(session_file)

    if session_file is# ''
        return 'echoerr "No session to load"'
    elseif !filereadable(session_file)
        return 'echoerr '..string(printf("%s doesn't exist, or it's not readable", fnamemodify(session_file, ':t')))
    elseif exists('g:my_session') && session_file is# g:my_session
        return 'echoerr '..string(printf('%s is already the current session', fnamemodify(session_file, ':t')))
    endif

    call s:prepare_restoration(session_file)

    if exists('g:my_session')
        let g:MY_PENULTIMATE_SESSION = g:my_session
    endif

    call s:tweak_session_file(session_file)
    sil! exe 'so '..fnameescape(session_file)

    if exists('g:my_session')
        let g:MY_LAST_SESSION = g:my_session
    endif

    call s:rename_tmux_window(session_file)

    do <nomodeline> WinEnter

    return ''
endfu

fu s:load_session_on_vimenter() abort
    let file = $HOME..'/.local/share/nvim/session/last'
    if filereadable(file)
        let g:MY_LAST_SESSION = get(readfile(file), 0, '')
    endif
    if s:safe_to_load_session()
        exe 'SLoad '..g:MY_LAST_SESSION
    endif
endfu

fu s:prepare_restoration(file) abort
    exe s:track(0)
    sil tabonly | sil only
endfu

fu s:rename(new_name) abort
    let src = g:my_session
    let dst = expand(s:SESSION_DIR..'/'..a:new_name..'.vim')
    if rename(src, dst)
        return 'echoerr '..string('Failed to rename '..src..' to '..dst)
    else
        let g:my_session = dst
        call s:rename_tmux_window(dst)
    endif
    return ''
endfu

fu s:rename_tmux_window(file) abort
    if !exists('$TMUX') | return | endif
    let window_title = fnamemodify(a:file, ':t:r')
    sil call system('tmux rename-window -t '..$TMUX_PANE..' '..shellescape(window_title))
    augroup my_tmux_window_title | au!
        au VimLeavePre * sil call system('tmux set-option -w -t '..$TMUX_PANE..' automatic-rename on')
    augroup END
endfu

fu s:safe_to_load_session() abort
    return !argc()
      \ && !get(s:, 'read_stdin', 0)
      \ && &errorfile is# 'errors.err'
      \ && filereadable(get(g:, 'MY_LAST_SESSION', s:SESSION_DIR..'/default.vim'))
      \ && !s:session_loaded_in_other_instance(get(g:, 'MY_LAST_SESSION', s:SESSION_DIR..'/default.vim'))
endfu

fu s:session_loaded_in_other_instance(session_file) abort
    if !exists('$TMUX') | return 0 | endif

    let new_title = fnamemodify(a:session_file, ':t:r')
    for win in systemlist('tmux list-windows -F "#{window_name}"')
        if win is# new_title
            return 1
        endif
    endfor
    return 0
endfu

fu s:session_delete() abort
    call delete(s:last_used_session)
    unlet! g:my_session
    echo 'Deleted session in '..fnamemodify(s:last_used_session, ':~:.')
    let v:this_session = ''
    return ''
endfu

fu s:session_pause() abort
    echo 'Pausing session in '..fnamemodify(s:last_used_session, ':~:.')
    let g:MY_LAST_SESSION = g:my_session
    unlet g:my_session
    return ''
endfu

fu s:should_delete_session() abort
    return s:bang && s:file is# '' && filereadable(s:last_used_session)
endfu

fu s:should_pause_session() abort
    return !s:bang && s:file is# '' && exists('g:my_session')
endfu

fu session#status() abort
    if v:this_session is# '' && !exists('g:my_session')
        return ''
    elseif v:this_session isnot# '' && exists('g:my_session')
        return '['.fnamemodify(g:my_session, ':t:r').']'
    else
        return '[]'
    endif
endfu

fu s:suggest_sessions(arglead, _l, _p) abort
    let files = glob(s:SESSION_DIR..'/*'..a:arglead..'*.vim')
    return substitute(files, '[^\n]*\.local/share/nvim/session/\([^\n]*\)\.vim', '\1', 'g')
endfu

fu s:track(on_vimleavepre) abort
    if exists('g:SessionLoad')
        return ''
    endif
    if exists('g:my_session')
        try
            exe 'mksession! '..fnameescape(g:my_session)
            let g:MY_LAST_SESSION = g:my_session
        catch /^Vim\%((\a\+)\)\=:E\%(788\|11\):/
        catch
            unlet! g:my_session
            redrawt
            redraws!
            return 'echoerr '..string(v:exception)
        endtry
    endif
    return ''
endfu

fu s:tweak_session_file(file) abort
    let body = readfile(a:file)
    call insert(body, 'let g:my_session = v:this_session', -3)
    call insert(body, 'let g:my_session = v:this_session', -3)
    call writefile(body, a:file)
endfu

fu s:where_do_we_save() abort
    if s:file is# ''
        if s:last_used_session is# ''
            if !isdirectory(s:SESSION_DIR)
                call mkdir(s:SESSION_DIR, 'p', 0700)
            endif
            return s:SESSION_DIR..'/default.vim'
        else
            return s:last_used_session
        endif
    " elseif isdirectory(s:file)
    "     echohl ErrorMsg
    "     echo 'provide the name of a session file; not a directory'
    "     echohl NONE
    "     return ''
    else
        return s:file =~# '/'
           \ ?     fnamemodify(s:file, ':p')
           \ :     s:SESSION_DIR..'/'..s:file..'.vim'
    endif
endfu

const s:SESSION_DIR = $HOME..'/.local/share/nvim/session'
call mkdir(s:SESSION_DIR, 'p')
