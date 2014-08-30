" run vimtest

let s:test = vimtest#new('ezbuffer#buffer#builder.vim test')

function! s:test.builder_new()
    let builder = ezbuffer#buffer#builder#new()

    call self.assert.equals(builder.name, '')
    call self.assert.equals(builder.keepalt, 0)
    call self.assert.equals(builder.keepjumps, 0)
    call self.assert.equals(builder.creation, 'edit')
    call self.assert.equals(builder.context, {})
endfunction

function! s:test.builder_build()
    let builder = ezbuffer#buffer#builder#new()

    call builder.set_name('test').set_keepalt(1).set_keepjumps(1).set_creation('sp').extend_context({'filetype': 'test'})
    call self.assert.equals(builder._create_command(), 'keepalt keepjumps sp test')

    let buffer = builder.build()
    call self.assert.equals(buffer.get_context('filetype'), 'test')
endfunction
