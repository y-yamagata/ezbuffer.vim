" run vimtest

let s:test = vimtest#new('ezbuffer#promt.vim test')

function! s:test.prompt_new()
    let prompt = ezbuffer#prompt#new('')
    call self.assert.equals(prompt.prompt, '> ')
    call self.assert.equals(prompt.get_ch(), '')

    let prompt = ezbuffer#prompt#new('test> ')
    call self.assert.equals(prompt.prompt, 'test> ')
endfunction

