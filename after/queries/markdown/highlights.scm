;; extends

;; nvim-treesitter's capture groups only include @text.title for titles, so we
;; make custom capture groups to highlight different level headings differently.
;;
;; See https://github.com/MDeiml/tree-sitter-markdown/issues/37

(atx_heading
  (atx_h1_marker) @text.title1
  heading_content: (inline) @text.title1)

(setext_heading (setext_h1_underline)) @text.title1

(atx_heading
  (atx_h2_marker) @text.title2
  heading_content: (inline) @text.title2)

(setext_heading (setext_h2_underline)) @text.title2

;; italic blockquote
(block_quote) @text.emphasis
