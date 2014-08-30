" ezbuffer.vim

if exists('g:ezbuffer#loaded')
    finish
endif
let g:ezbuffer#loaded = 1

let s:save_cpo = &cpo
set cpo&vim

" constant {{{
let s:BUFFER_NAME = '__ezbuffer__'
" }}}

" variable {{{
let s:ezbuffer = {}
" }}}

" ezbuffer instance functions {{{
function! s:extend(buffer, before_winnr)
    let ezbuffer = a:buffer
    let ezbuffer.winnr = winnr()
    let ezbuffer.before_winnr = a:before_winnr
    let ezbuffer.before_ward  = ''
    let ezbuffer.origins  = map(s:buffers(), '[v:val, s:bufname(v:val)]')
    let ezbuffer.currents = copy(ezbuffer.origins)
    let ezbuffer.prompt = {}

    function! ezbuffer.enter(line)
        let bufnr = self._buffer(a:line)
        if bufexists(bufnr)
            bwipeout!
            execute 'keepalt keepjumps ' . self.before_winnr . ' wincmd w'
            execute 'buffer ' . bufnr
        else
            echoerr 'no such buffer.'
            call self._remove(bufnr)
        endif
    endfunction

    function! ezbuffer.delete(line)
        try
            call self.set_context('modifiable', 1)
            call self._delete(a:line)
        finally
            call self.set_context('modifiable', 0)
        endtry
    endfunction

    function! ezbuffer._delete(line)
        let bufnr = self._buffer(a:line)
        if bufexists(bufnr)
            if ! getbufvar(bufnr, "&modified")
                execute 'bdelete ' . bufnr
                call self._remove(bufnr)
            else
                echoerr 'buffer is modified.'
            endif
        else
            echoerr 'no such buffer.'
            call self._remove(bufnr)
        endif
    endfunction

    function! ezbuffer._remove(bufnr)
        silent! normal! dd

        let i = 0
        for arg in self.origins
            if arg[0] == a:bufnr
                call remove(self.origins, i)
                break
            endif
            let i += 1
        endfor

        let i = 0
        for arg in self.currents
            if arg[0] == a:bufnr
                call remove(self.currents, i)
                break
            endif
            let i += 1
        endfor
    endfunction

    function! ezbuffer.close()
        bwipeout!
        execute 'keepalt keepjumps ' . self.before_winnr . ' wincmd w'
    endfunction

    function! ezbuffer.print(cursor_bufnr)
        try
            call self.set_context('modifiable', 1)
            silent! normal! ggdG
            call self._print(a:cursor_bufnr)
        finally
            call self.set_context('modifiable', 0)
        endtry
    endfunction

    function! ezbuffer._print(cursor_bufnr)
        let headers = ['<bufnr>', '<mode>', '<filetype>', '<bufname>',]
        call setline(1, join(headers, '  '))

        let l = 2
        for [b, name] in self.currents
            let values = []
            call add(values, s:centering(string(b), len(headers[0])))
            call add(values, s:centering(s:mode(b), len(headers[1])))
            call add(values, s:centering(s:filetype(b), len(headers[2])))
            call add(values, name)

            call setline(l, join(values, '  '))
            if b == a:cursor_bufnr
                call cursor(l, 0)
            endif

            let l += 1
        endfor
    endfunction

    function! ezbuffer._buffer(line)
        let header = 1
        if a:line > header && (a:line - header - 1) < len(self.currents)
            return self.currents[a:line - header - 1][0]
        endif
        throw 'line error.'
    endfunction

    function! ezbuffer.search()
        let self.prompt = ezbuffer#prompt#new('>>> ')
        call self.prompt.execute('')
    endfunction

    function! ezbuffer.pickup()
        let pattern = self.prompt.get_str()
        " TODO: implement fuzzy search
        " let pattern = join(split(word, '\zs'), '.*')
        let candidates = copy(self.origins)

        let self.currents = filter(candidates, 'match(v:val[1], "' . pattern . '") >= 0')
        call self.print(-1)
    endfunction

    return ezbuffer
endfunction

function! s:new()
    let before_winnr = winnr()

    let builder = ezbuffer#buffer#builder#new()
    call builder.set_keepalt(1)
            \.set_keepjumps(1)
            \.set_creation(printf('belowright %d sp', winheight('%') / 4))
            \.set_name(s:BUFFER_NAME)
            \.extend_context({
                \'filetype': 'ezbuffer',
                \'buftype': 'nofile',
                \'bufhidden': 'wipe',
                \'buflisted': 0,
                \'swapfile': 0,
                \'number': 0,
                \'wrap': 0,
                \'modifiable': 0,
                \'cursorline': 1,
            \})

    let buffer   = builder.build()
    let ezbuffer = s:extend(buffer, before_winnr)

    return ezbuffer
endfunction
" }}}

" utility {{{
function! s:winexists(name)
    let winnr = bufwinnr(a:name)
    if winnr < 0
        return 0
    endif
    return 1
endfunction

function! s:buffers()
    return filter(range(1, bufnr('$')), 'bufexists(v:val) && buflisted(v:val) && getbufvar(v:val, "&filetype") != "ezbuffer"')
endfunction

function! s:centering(text, len)
    if len(a:text) > a:len
        return a:text[: a:len - 2] . '~'
    else
        let d = a:len - len(a:text)
        let c = d / 2
        let r = d % 2
        let text = repeat(' ', c) . a:text . repeat(' ', c) . repeat(' ', r)
    endif
    return text
endfunction

function! s:filetype(bufnr)
    let ftype = getbufvar(a:bufnr, '&filetype')
    if empty(ftype)
        return '-'
    endif
    return ftype
endfunction

function! s:bufname(bufnr)
    let bufname = bufname(a:bufnr)
    if empty(bufname)
        return '[No Name]'
    endif
    return bufname
endfunction

function! s:mode(bufnr)
    let mode = ''
    if !buflisted(a:bufnr)
        let mode .= 'u'
    endif
    if bufwinnr('%') == bufwinnr(a:bufnr)
        let mode .= '%'
    elseif bufnr('#') == a:bufnr
        let mode .= '#'
    endif
    if winbufnr(bufwinnr(a:bufnr)) == a:bufnr
        let mode .= 'a'
    else
        let mode .= 'h'
    endif
    if !getbufvar(a:bufnr, "&modifiable")
        let mode .= '-'
    elseif getbufvar(a:bufnr, "&readonly")
        let mode .= '='
    endif
    if getbufvar(a:bufnr, "&modified")
        let mode .= '+'
    endif

    return mode
endfunction
" }}}

" glue function {{{
function! s:delete()
    call s:ezbuffer.delete(line('.'))
endfunction

function! s:enter()
    call s:ezbuffer.enter(line('.'))
endfunction

function! s:reflesh()
    call s:ezbuffer.print(-1)
endfunction

function! s:search()
    call s:ezbuffer.search()
endfunction

function! s:close()
    call s:ezbuffer.close()
endfunction

function! s:pickup()
    call s:ezbuffer.pickup()
endfunction
" }}}

augroup ezbuffer_commands
    autocmd!
    autocmd User EzBufferPromptStart call s:pickup()
    autocmd User EzBufferPromptPostWrite call s:pickup()
augroup END

" external functions {{{
function! ezbuffer#open()
    if s:winexists(s:BUFFER_NAME)
        execute 'keepalt keepjumps ' . s:ezbuffer.winnr . ' wincmd w'
        return
    endif
    let cursor_bufnr = bufnr('%')

    let s:ezbuffer = s:new()
    call s:ezbuffer.print(cursor_bufnr)

    nnoremap <silent> <buffer> d :call <SID>delete()<CR>
    nnoremap <silent> <buffer> <Enter> :call <SID>enter()<CR>
    nnoremap <silent> <buffer> <C-j> :call <SID>enter()<CR>
    nnoremap <silent> <buffer> e :call <SID>enter()<CR>
    nnoremap <silent> <buffer> r :call <SID>reflesh()<CR>
    nnoremap <silent> <buffer> <C-p> :call <SID>search()<CR>
    nnoremap <silent> <buffer> q :call <SID>close()<CR>
    nnoremap <silent> <buffer> <Esc> :call <SID>close()<CR>
endfunction
" }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set fdm=marker:
