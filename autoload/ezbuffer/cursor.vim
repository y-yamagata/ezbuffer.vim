" cursor.vim

if exists('g:ezbuffer#cursor#loaded')
    finish
endif
let g:ezbuffer#cursor#loaded = 1

let s:save_cpo = &cpo
set cpo&vim

function! ezbuffer#cursor#new(input)
    if type(a:input) != type({})
        throw 'invalid arguments error.'
    endif

    let cursor = {}
    let cursor.input = a:input
    let cursor.p = cursor.input.length()

    function! cursor.write(str)
        call self.input.write(a:str, self.p)
        let self.p += strchars(a:str)
    endfunction

    function! cursor.back()
        let self.p = max([self.p - 1, 0])
    endfunction

    function! cursor.next()
        let self.p = min([self.p + 1, self.input.length()])
    endfunction

    function! cursor.top()
        let self.p = 0
    endfunction

    function! cursor.end()
        let self.p = self.input.length()
    endfunction

    function! cursor.backspace()
        if self.p <= 0
            return
        endif

        call self.back()
        call self.input.delete(self.p)
    endfunction

    function! cursor.delete()
        if self.p < 0 || self.p >= self.input.length()
            return
        endif

        call self.input.delete(self.p)
    endfunction

    function! cursor.clear()
        call self.input.clear(self.p)
        let self.p = 0
    endfunction

    function! cursor.begin_highlight()
        if !hlexists('Cursor')
            return
        endif
        echohl Cursor
    endfunction

    function! cursor.end_highlight()
        echohl None
    endfunction

    return cursor
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set fdm=marker:
