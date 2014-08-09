" ezbuffer.vim

if exists('g:ezbuffer_loaded')
    finish
endif
let g:ezbuffer_loaded = 1

let s:save_cpo = &cpo
set cpo&vim

let s:bufferName = '__ezbuffer__'

" utility {{{
function! s:centering(text, len)
    if len(a:text) > a:len
        return a:text[: a:len - 2] . '~'
    else
        let l:d = a:len - len(a:text)
        let l:c = l:d / 2
        let l:r = l:d % 2
        let l:text = repeat(' ', l:c) . a:text . repeat(' ', l:c) . repeat(' ', l:r)
    endif
    return l:text
endfunction

function! s:wrapModifiable(order)
    setlocal modifiable
    execute a:order
    setlocal nomodifiable
endfunction
" }}}

" buffer variables {{{ 
function! s:getBufVar(key)
    return getbufvar(s:bufferName, a:key)
endfunction

function! s:setBufVar(key, value)
    call setbufvar(s:bufferName, a:key, a:value)
endfunction
" }}}

" ezbuffer {{{
function! s:mapBufKeys()
    nnoremap <silent> <buffer> d :call <SID>deleteBuffer()<CR>
    nnoremap <silent> <buffer> q :call <SID>closeBuffer()<CR>
    nnoremap <silent> <buffer> <Enter> :call <SID>enterBuffer()<CR>
endfunction

function! s:buildBufMode(buf)
    let mode = ''
    if !buflisted(a:buf)
        let mode .= 'u'
    endif
    if bufwinnr('%') == bufwinnr(a:buf)
        let mode .= '%'
    elseif bufnr('#') == a:buf
        let mode .= '#'
    endif
    if winbufnr(bufwinnr(a:buf)) == a:buf
        let mode .= 'a'
    else
        let mode .= 'h'
    endif
    if !getbufvar(a:buf, "&modifiable")
        let mode .= '-'
    elseif getbufvar(a:buf, "&readonly")
        let mode .= '='
    endif
    if getbufvar(a:buf, "&modified")
        let mode .= '+'
    endif

    return mode
endfunction

function! s:getBufNr(line)
    let l:header = 1
    let l:buffers = s:getBufVar('buffers')
    if a:line > l:header && (a:line - l:header) <= len(l:buffers)
        return l:buffers[a:line - l:header - 1]
    endif
    throw 'line error.'
endfunction

function! s:removeBuffer(bufNr)
    call s:wrapModifiable('normal! dd')

    let l:buffers = s:getBufVar('buffers')
    let l:i = 0
    for l:buf in l:buffers
        if l:buf == a:bufNr
            call remove(l:buffers, i)
            break
        endif
        let l:i += 1
    endfor
endfunction

function! s:deleteBuffer()
    try
        let l:bufNr = s:getBufNr(line('.'))
    catch
        echoerr v:exception
    endtry

    if bufexists(l:bufNr)
        if ! getbufvar(l:bufNr, "&modified")
            execute 'bdelete ' . l:bufNr
            call s:removeBuffer(l:bufNr)
        else
            echoerr 'buffer is modified.'
        endif
    else
        echoerr 'no such buffer.'
        call s:removeBuffer(l:bufNr)
    endif
endfunction

function! s:enterBuffer()
    try
        let l:bufNr = s:getBufNr(line('.'))
    catch
        echoerr v:exception
    endtry

    if bufexists(l:bufNr)
        let l:winNr = s:getBufVar('beforeWinNr')
        bwipeout!
        execute printf('keepalt keepjumps %d wincmd w', l:winNr)
        execute 'buffer ' . l:bufNr
    else
        echoerr 'no such buffer.'
        call s:removeBuffer(l:bufNr)
    endif
endfunction

function! s:listBuffer(cursorBuf)
    let l:keys = [
        \ '<bufnr>',
        \ '<mode>',
        \ '<filetype>',
        \ '<bufname>',
    \ ]
    let l:glue = '  '
    call setline(1, join(l:keys, l:glue))

    let l:buffers = filter(range(1, bufnr('$')), 'bufexists(v:val) && buflisted(v:val) && getbufvar(v:val, "&filetype") != "ezbuffer"')
    let l:l = 2
    let l:values = []
    for l:buf in l:buffers
        call add(l:values, s:centering(string(l:buf), len(l:keys[0])))
        call add(l:values, s:centering(s:buildBufMode(l:buf), len(l:keys[1])))
        let l:ftype = getbufvar(l:buf, '&filetype')
        call add(l:values, s:centering(len(l:ftype) > 0 ? l:ftype : '-', len(l:keys[2])))
        let l:bufName = bufname(l:buf)
        call add(l:values, len(l:bufName) > 0 ? l:bufName : '[No Name]')

        call setline(l:l, join(l:values, l:glue))
        " move cursor
        if l:buf == a:cursorBuf
            call cursor(l:l, 0)
        endif

        let l:l += 1
        let l:values = []
    endfor

    call s:setBufVar('buffers', l:buffers)
endfunction

function! s:createBuffer(height)
    let l:beforeWinNr = winnr()
    let l:bufNr = bufnr('%')

    execute printf('keepalt keepjumps belowright %d sp %s', a:height, s:bufferName)
    setlocal filetype=ezbuffer buftype=nofile bufhidden=wipe nobuflisted noswapfile nonumber nowrap cursorline nomodifiable
    call s:setBufVar('beforeWinNr', l:beforeWinNr)
    call s:wrapModifiable(printf('call s:listBuffer(%d)', l:bufNr))
    call s:mapBufKeys()
endfunction

function! s:closeBuffer()
    let l:winNr = s:getBufVar('beforeWinNr')
    bwipeout!
    execute printf('keepalt keepjumps %d wincmd w', l:winNr)
endfunction

function! s:openBuffer(height)
    let l:ezBufNr = bufwinnr(printf('^%s$', s:bufferName))
    if l:ezBufNr < 0
        call s:createBuffer(a:height)
    else
        execute printf('keepalt keepjumps %d wincmd w', l:ezBufNr)
    endif
endfunction
" }}}

function! ezbuffer#openBuffer()
    let l:height = winheight('%') / 4
    if l:height < 0
        echoerr 'not enough room.'
        return
    endif

    call s:openBuffer(l:height)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set fdm=marker:
