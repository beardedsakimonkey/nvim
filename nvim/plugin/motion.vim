" function MyMotion()
"     let l:isk_save = &isk
"     set isk+=.
"     try
"         let s:pat = '\v\k+|^|$'
"         normal! l
"         call search(s:pat, 'Wb')
"         normal! v
"         call search(s:pat, 'We')
"     finally
"         let &isk = l:isk_save
"     endtry
" endfunction

" onoremap o <Cmd>call MyMotion()<CR>
