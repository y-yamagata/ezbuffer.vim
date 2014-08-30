" run vimtest

let s:test = vimtest#new('ezbuffer#buffer.vim test')

function! s:test.buffer_new()
    let buffer = ezbuffer#buffer#new('test', {'filetype': 'test'})

    call self.assert.equals(buffer.get_context('filetype'), 'test')
endfunction

function! s:test.buffer_set()
    let buffer = ezbuffer#buffer#new('test', {})

    call buffer.set('test', 'test')
    call self.assert.equals(buffer.get('test'), 'test')
endfunction
