" prompt.vim

if exists('g:ezbuffer#prompt#loaded')
    finish
endif
let g:ezbuffer#prompt#loaded = 1

let s:save_cpo = &cpo
set cpo&vim

let s:commands = {}

function! ezbuffer#prompt#new(prompt)
    let prompt = {}
    let prompt.prompt = empty(a:prompt) ? '> ' : a:prompt
    let prompt.ch = ''

    function! prompt.execute(str)
        let self.input  = ezbuffer#input#new(a:str)
        let self.cursor = ezbuffer#cursor#new(self.input)

        call self._line()
        let self.ch = s:getchar()
        while self.ch != "\<CR>" && self.ch != "\<C-j>"
            if self.ch == "\<Esc>"
                return ''
            endif

            let action = get(self.key_map, self.ch, '')
            if !empty(action)
                call call(action, [], self)
                continue
            endif

            call s:do_command('PromptPreWrite')
            call self.cursor.write(self.ch)
            call s:do_command('PromptPostWrite')

            call self._line()
            let self.ch = getchar()
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

        echo self.prompt

        echon self.input.slice(0, pos - 1)
        call self.cursor.begin_highlight()
        echon cursor_ch
        call self.cursor.end_highlight()
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
        \ "\<C-p>" : '',
        \ "\<C-n>" : '',
    \ }

    return prompt
endfunction

function! s:getchar()
    let c = getchar()
    return type(c) == type(0) ? nr2char(c) : c
endfunction

function! s:do_command(command)
    if !has_key(s:commands, a:command)
        execute 'autocmd __dummy_commands__ User ' . a:command . ' silent! execute ""'
        let s:commands[a:command] = 'doautocmd User ' . a:command
    endif

    execute s:commands[a:command]
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set fdm=marker:
