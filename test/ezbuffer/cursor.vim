" run vimtest

let s:test = vimtest#new('ezbuffer#cursor.vim test')

function! s:test.cursor_new()
    let cursor = ezbuffer#cursor#new(ezbuffer#input#new('test'))
    call self.assert.equals(cursor.p, 4)

    try
        let cursor = ezbuffer#cursor#new('test')
        call self.assert.fail()
    catch
        call self.assert.equals(v:exception, 'invalid arguments error.')
    endtry
endfunction

function! s:test.cursor_write()
    let cursor = ezbuffer#cursor#new(ezbuffer#input#new('test'))

    call cursor.write('hoge')
    call self.assert.equals(cursor.input.to_str(), 'testhoge')
    call self.assert.equals(cursor.p, 8)
endfunction

function! s:test.cursor_back()
    let cursor = ezbuffer#cursor#new(ezbuffer#input#new('test'))

    call cursor.back()
    call self.assert.equals(cursor.p, 3)

    let cursor.p = 0
    call cursor.back()
    call self.assert.equals(cursor.p, 0)
endfunction

function! s:test.cursor_next()
    let cursor = ezbuffer#cursor#new(ezbuffer#input#new('test'))

    call cursor.next()
    call self.assert.equals(cursor.p, 4)

    let cursor.p = 1
    call cursor.next()
    call self.assert.equals(cursor.p, 2)
endfunction

function! s:test.cursor_top()
    let cursor = ezbuffer#cursor#new(ezbuffer#input#new('test'))

    call cursor.top()
    call self.assert.equals(cursor.p, 0)
endfunction

function! s:test.cursor_end()
    let cursor = ezbuffer#cursor#new(ezbuffer#input#new('test'))

    let cursor.p = 0
    call cursor.end()
    call self.assert.equals(cursor.p, 4)
endfunction

function! s:test.cursor_backspace()
    let cursor = ezbuffer#cursor#new(ezbuffer#input#new('test'))

    call cursor.backspace()
    call self.assert.equals(cursor.p, 3)
    call self.assert.equals(cursor.input.to_str(), 'tes')

    let cursor.p = 0
    call cursor.backspace()
    call self.assert.equals(cursor.p, 0)
    call self.assert.equals(cursor.input.to_str(), 'tes')
endfunction

function! s:test.cursor_delete()
    let cursor = ezbuffer#cursor#new(ezbuffer#input#new('test'))

    call cursor.delete()
    call self.assert.equals(cursor.input.to_str(), 'test')

    let cursor.p = 2
    call cursor.delete()
    call self.assert.equals(cursor.input.to_str(), 'tet')

    let cursor.p = 0
    call cursor.delete()
    call self.assert.equals(cursor.input.to_str(), 'et')
endfunction

function! s:test.cursor_clear()
    let cursor = ezbuffer#cursor#new(ezbuffer#input#new('test'))

    call cursor.clear()
    call self.assert.equals(cursor.input.to_str(), '')
endfunction
