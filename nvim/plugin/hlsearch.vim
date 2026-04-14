" Adapted from romainl/vim-cool
aug my_hlsearch | au!
  au CursorMoved * call HlSearch()
  au InsertEnter * call StopHL()

  fu! HlSearch()
    " bail out if cursor is at top/bottom of window
    let wininfo = getwininfo(win_getid())[0]
    let lnum = getcurpos()[1]
    if lnum == wininfo.botline - &scrolloff || lnum == wininfo.topline + &scrolloff
      return
    endif

    try
      let pos = match(getline('.'), @/, col('.') - 1) + 1
      if pos != col('.')
        call StopHL()
      endif
    catch
      call StopHL()
    endtry
  endfu

  fu! StopHL()
    if !v:hlsearch || mode() isnot# 'n'
      return
    endif
    sil call feedkeys("\<Plug>(StopHL)", 'm')
  endfu

  no <silent> <Plug>(StopHL) :<C-U>nohlsearch<cr>
  no! <expr> <Plug>(StopHL) execute('nohlsearch')[-1]
aug END
