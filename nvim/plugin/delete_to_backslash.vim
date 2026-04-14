" Lua doesn't have try/finally
function s:delete_to_backslash()
	let l:isk_save = &isk
	set isk+=/
	" Doesn't work for some reason
	" set isk-=.
	try
		return "\<C-w>"
	finally
		let &isk = l:isk_save
	endtry
endfu

cnoremap <expr> <C-w> <SID>delete_to_backslash()
