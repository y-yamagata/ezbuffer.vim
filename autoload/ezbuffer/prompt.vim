" prompt.vim

if exists('g:ezbuffer#prompt#loaded')
    finish
endif
let g:ezbuffer#prompt#loaded = 1

let s:save_cpo = &cpo
set cpo&vim

augroup ezbuffer_prompt_dummy_commands
    autocmd!
    autocmd User EzBufferPromptStart silent! execute ''
    autocmd User EzBufferPromptPreWrite silent! execute ''
    autocmd User EzBufferPromptPostWrite silent! execute ''
augroup END

let s:commands = {}

function! ezbuffer#prompt#new(prompt)
    let prompt = {}
    let prompt.prompt = empty(a:prompt) ? '> ' : a:prompt
    let prompt.ch = ''

    " TODO: function ref variable name
    function! prompt.execute(str)
        let self.input  = ezbuffer#input#new(a:str)
        let self.cursor = ezbuffer#cursor#new(self.input)
        let Dummy = function('s:dummy')

        doautocmd User EzBufferPromptStart

        call self._line()
        let self.ch = s:getchar()
        while self.ch != "\<CR>" && self.ch != "\<C-j>"
            if self.ch == "\<Esc>"
                return ''
            endif

            doautocmd User EzBufferPromptPreWrite

            let Action = get(self.key_map, self.ch, Dummy)
            if Action != Dummy
                call call(Action, [], self)
            else
                call self.cursor.write(self.ch)
            endif

            doautocmd User EzBufferPromptPostWrite

            call self._line()
            let self.ch = s:getchar()
        endwhile

        return self.get_str()
    endfunction

    function! prompt.get_ch()
        return self.ch
    endfunction

    function! prompt.get_str()
        return self.input.to_str()
    endfunction

    function! prompt._line()
        let pos = self.cursor.pos()
        let cursor_ch = empty(self.input.at(pos)) ? ' ' : self.input.at(pos)

        redraw
        echon self.prompt
        if pos > 0 | echon self.input.slice(0, pos - 1) | endif
        call self.cursor.echonhl(cursor_ch)
        echon self.input.slice(pos + 1)
    endfunction

    function! prompt._back()
        call self.cursor.back()
    endfunction

    function! prompt._next()
        call self.cursor.next()
    endfunction

    function! prompt._top()
        call self.cursor.top()
    endfunction

    function! prompt._end()
        call self.cursor.end()
    endfunction

    function! prompt._backspace()
        call self.cursor.backspace()
    endfunction

    function! prompt._delete()
        call self.cursor.delete()
    endfunction

    function! prompt._clear()
        call self.cursor.clear()
    endfunction

    let prompt.key_map = {
        \ "\<C-b>" : prompt._back,
        \ "\<C-f>" : prompt._next,
        \ "\<C-a>" : prompt._top,
        \ "\<C-e>" : prompt._end,
        \ "\<C-h>" : prompt._backspace,
        \ "\<C-d>" : prompt._delete,
        \ "\<C-u>" : prompt._clear,
        \ "\<C-p>" : function('s:dummy'),
        \ "\<C-n>" : function('s:dummy'),
    \ }

    return prompt
endfunction

function! s:getchar()
    let c = getchar()
    return type(c) == type(0) ? nr2char(c) : c
endfunction

function! s:dummy()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set fdm=marker:
