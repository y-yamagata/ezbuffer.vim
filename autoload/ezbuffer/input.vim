" input.vim

if exists('g:ezbuffer#input#loaded')
    finish
endif
let g:ezbuffer#input#loaded = 1

let s:save_cpo = &cpo
set cpo&vim

function! ezbuffer#input#new(str)
    let input = {}
    let input.str = a:str

    function! input.to_str()
        return self.str
    endfunction

    function! input.at(pos)
        return self.str[a:pos]
    endfunction

    function! input.slice(start, ...)
        if empty(a:000)
            return self.str[a:start :]
        endif
        return self.str[a:start : a:1]
    endfunction

    function! input.length()
        return strchars(self.str)
    endfunction

    function! input.write(str, pos)
        let forward = a:pos > 0 ? self.str[0 : a:pos - 1] : ''
        let self.str = forward . a:str . self.str[a:pos :]
    endfunction

    function! input.delete(pos)
        let forward = a:pos > 0 ? self.str[0 : a:pos - 1] : ''
        let self.str = forward . self.str[a:pos + 1 :]
    endfunction

    function! input.clear(pos)
        let self.str = self.str[a:pos :]
    endfunction

    return input
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set fdm=marker:
