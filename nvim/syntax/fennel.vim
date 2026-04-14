" Quit if a syntax file was already loaded.
if exists("b:current_syntax")
    finish
endif

runtime! syntax/lisp.vim
