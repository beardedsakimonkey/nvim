;; extends

;; Highlight keyword-style strings (e.g. `:foo`) as keyword
((string) @keyword (#match? @keyword "^:"))

[
  "("
  ")"
  "{"
  "}"
  "["
  "]"
] @comment

"λ" @keyword.function

((symbol) @function.builtin
 (#any-of? @function.builtin
  "not" "not=" "or" "and"))

;; My macros
((symbol) @function.macro
 (#any-of? @function.macro
  "map" "command" "augroup" "autocmd" "opt" "opt-local" "map" "undo-ftplugin" "with-undo-ftplugin"))

(ERROR) @error
