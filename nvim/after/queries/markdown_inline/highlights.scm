;; extends

; Underline [text](url) links only. Shortcut links are left out because `[~]`-style
; checkboxes parse as one; wikilinks get theirs from render-markdown's scope highlight.
(inline_link (link_text) @markup.link.underline)
