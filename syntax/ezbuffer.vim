" ezbuffer.vim

if exists('b:current_syntax')
    finish
endif
let b:current_syntax = "ezbuffer"

let s:save_cpo = &cpo
set cpo&vim

syntax match EzBufferTag /\(\:\?<\zsbufnr\ze>\)\|\(\:\?<\zsmode\ze>\)\|\(\:\?<\zsfiletype\ze>\)\|\(\:\?<\zsbufname\ze>\)/
syntax match EzBufferBufNr /^\s*\d\+\s\+/
syntax match EzBufferMode /\s\+u\?[%#]\?[ah][=-]\?+\?\s\+/
syntax match EzBufferFileType /\zs[^\s>]\+\ze\s\+/
syntax match EzBufferFileName /[ /]\zs[^ />]\+\ze$/

highlight default link EzBufferTag Identifier
highlight default link EzBufferBufNr Number
highlight default link EzBufferMode Keyword
highlight default link EzBufferFileType Type
highlight default link EzBufferFileName Keyword

let &cpo = s:save_cpo
unlet s:save_cpo

