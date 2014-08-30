" buffer.vim

if exists('g:ezbuffer#buffer#loaded')
    finish
endif
let g:ezbuffer#buffer#loaded = 1

let s:save_cpo = &cpo
set cpo&vim

function! ezbuffer#buffer#new(name, context)
    if type(a:name) != type('')
        throw 'invalid arguments error.'
    endif

    let buffer = {}
    " buffer is maked if buffer doesn't exist.
    let buffer.id = bufnr('^' . a:name . '$', 1)
    let buffer.name = a:name

    function! buffer.set_context(key, value)
        call self.set('&' . a:key, a:value)
    endfunction

    function! buffer.set_contexts(context)
        for key in keys(a:context)
            call self.set_context(key, get(a:context, key))
        endfor
    endfunction

    function! buffer.get_context(key)
        return self.get('&' . a:key)
    endfunction

    function! buffer.set(key, value)
        call setbufvar(self.id, a:key, a:value)
    endfunction

    function! buffer.get(key)
        return getbufvar(self.id, a:key)
    endfunction

    call buffer.set_contexts(a:context)

    return buffer
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set fdm=marker:
