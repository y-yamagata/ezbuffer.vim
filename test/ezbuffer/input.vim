" run vimtest

let s:test = vimtest#new('ezbuffer#input.vim test')

function! s:test.input_new()
    let input = ezbuffer#input#new('test')

    call self.assert.equals(input.str, 'test')
endfunction

function! s:test.input_to_str()
    let input = ezbuffer#input#new('test')

    call self.assert.equals(input.to_str(), 'test')
endfunction

function! s:test.input_at()
    let input = ezbuffer#input#new('test')

    call self.assert.equals(input.at(0), 't')
    call self.assert.equals(input.at(3), 't')
    call self.assert.equals(input.at(4), '')
    call self.assert.equals(input.at(-1), '')
endfunction

function! s:test.input_slice()
    let input = ezbuffer#input#new('test')

    call self.assert.equals(input.slice(0, 2), 'tes')
    call self.assert.equals(input.slice(4, 5), '')
    call self.assert.equals(input.slice(1), 'est')
endfunction

function! s:test.input_length()
    let input = ezbuffer#input#new('test')

    call self.assert.equals(input.length(), 4)
endfunction

function! s:test.input_write()
    let input = ezbuffer#input#new('test')

    call input.write('hoge', 4)
    call self.assert.equals(input.to_str(), 'testhoge')
    call input.write('piyo', 0)
    call self.assert.equals(input.to_str(), 'piyotesthoge')
endfunction

function! s:test.input_delete()
    let input = ezbuffer#input#new('test')

    call input.delete(0)
    call self.assert.equals(input.to_str(), 'est')
    call input.delete(3)
    call self.assert.equals(input.to_str(), 'est')
endfunction

function! s:test.input_clear()
    let input = ezbuffer#input#new('test')

    call input.clear(0)
    call self.assert.equals(input.to_str(), 'test')
    call input.clear(2)
    call self.assert.equals(input.to_str(), 'st')
endfunction
