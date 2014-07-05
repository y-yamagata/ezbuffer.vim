" ezbuffer.vim

let s:save_cpo = &cpo
set cpo&vim

command! EzBuffer call ezbuffer#openBuffer()

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set fdm=marker:
