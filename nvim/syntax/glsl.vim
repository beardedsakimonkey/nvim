" Adapted from https://github.com/tikhomirov/vim-glsl/blob/master/syntax/glsl.vim
if exists("b:current_syntax") && b:current_syntax == "glsl"
  finish
endif

" Statements
syn keyword glslConditional if else switch case default
syn keyword glslRepeat      for while do
syn keyword glslStatement   discard return break continue

" Comments
syn keyword glslTodo     contained TODO FIXME XXX NOTE
syn region  glslCommentL start="//" skip="\\$" end="$" keepend contains=glslTodo,@Spell
syn region  glslComment  matchgroup=glslCommentStart start="/\*" end="\*/" extend contains=glslTodo,@Spell

" Preprocessor
syn region  glslPreCondit       start="^\s*#\s*\(if\|ifdef\|ifndef\|else\|elif\|endif\)" skip="\\$" end="$" keepend
syn region  glslDefine          start="^\s*#\s*\(define\|undef\)" skip="\\$" end="$" keepend
syn keyword glslTokenConcat     ##
syn region  glslPreProc         start="^\s*#\s*\(error\|pragma\|extension\|version\|line\)" skip="\\$" end="$" keepend

" Boolean Constants
syn keyword glslBoolean true false

" Integer Numbers
syn match glslDecimalInt display "\<\(0\|[1-9]\d*\)[uU]\?"
syn match glslOctalInt   display "\<0\o\+[uU]\?"
syn match glslHexInt     display "\<0[xX]\x\+[uU]\?"

" Float Numbers
syn match glslFloat display "\<\d\+\.\([eE][+-]\=\d\+\)\=\(lf\|LF\|f\|F\)\="
syn match glslFloat display "\<\.\d\+\([eE][+-]\=\d\+\)\=\(lf\|LF\|f\|F\)\="
syn match glslFloat display "\<\d\+[eE][+-]\=\d\+\(lf\|LF\|f\|F\)\="
syn match glslFloat display "\<\d\+\.\d\+\([eE][+-]\=\d\+\)\=\(lf\|LF\|f\|F\)\="

" Swizzles
syn match glslSwizzle display /\.[xyzw]\{1,4\}\>/
syn match glslSwizzle display /\.[rgba]\{1,4\}\>/
syn match glslSwizzle display /\.[stpq]\{1,4\}\>/

syn match glslIdentifier contains=glslIdentifierPrime "\%([a-zA-Z_]\)\%([a-zA-Z0-9_]\)*" display contained

syn keyword glslBuiltinFunction abs
syn keyword glslBuiltinFunction sin
syn keyword glslBuiltinFunction cos
syn keyword glslBuiltinFunction min
syn keyword glslBuiltinFunction mix
syn keyword glslBuiltinFunction mod
syn keyword glslBuiltinFunction log
syn keyword glslBuiltinFunction fract
syn keyword glslBuiltinFunction floor
syn keyword glslBuiltinFunction ceil
syn keyword glslBuiltinFunction distance
syn keyword glslBuiltinFunction dot
syn keyword glslBuiltinFunction exp
syn keyword glslBuiltinFunction pow
syn keyword glslBuiltinFunction sign
syn keyword glslBuiltinFunction step
syn keyword glslBuiltinFunction smoothstep
syn keyword glslBuiltinFunction sqrt
syn keyword glslBuiltinFunction tan

syn keyword glslBuiltinVariable gl_FragColor
syn keyword glslBuiltinVariable gl_FragCoord

syn keyword glslType vec2
syn keyword glslType vec3
syn keyword glslType vec4

hi def link glslPreCondit       Keyword
hi def link glslConditional     Conditional
hi def link glslRepeat          Repeat
hi def link glslStatement       Statement
hi def link glslTodo            Todo
hi def link glslCommentL        glslComment
hi def link glslCommentStart    glslComment
hi def link glslComment         Comment
hi def link glslDefine          Define
hi def link glslTokenConcat     glslPreProc
hi def link glslPreProc         PreProc
hi def link glslBoolean         Boolean
hi def link glslDecimalInt      glslInteger
hi def link glslOctalInt        glslInteger
hi def link glslHexInt          glslInteger
hi def link glslInteger         Number
hi def link glslFloat           Float
hi def link glslIdentifierPrime glslIdentifier
hi def link glslIdentifier      Identifier
hi def link glslSwizzle         Identifier

hi def link glslBuiltinFunction Function
hi def link glslBuiltinVariable Identifier
hi def link glslType            Type
