" buffer/builder.vim

if exists('g:ezbuffer#buffer#builder#loaded')
    finish
endif
let g:ezbuffer#buffer#builder#loaded = 1

let s:save_cpo = &cpo
set cpo&vim

function! ezbuffer#buffer#builder#new()
    let builder = {}
    let builder.name = ''
    let builder.keepalt = 0
    let builder.keepjumps = 0
    " TODO: to divide into each purpose.
    let builder.creation = 'edit'
    " FIXME
    let builder.context = {}

    function! builder.build()
        call self._execute()
        return ezbuffer#buffer#new(self.name, self.context)
    endfunction

    function! builder._execute()
        let command = self._create_command()
        execute command
    endfunction

    function! builder._create_command()
        let command = ''

        if self.keepalt
            let command .= 'keepalt '
        endif
        if self.keepjumps
            let command .= 'keepjumps '
        endif
        let command .= self.creation . ' ' . self.name

        return command
    endfunction

    function! builder.set_name(name)
        let self.name = a:name
        return self
    endfunction

    function! builder.set_keepalt(value)
        let self.keepalt = a:value
        return self
    endfunction

    function! builder.set_keepjumps(value)
        let self.keepjumps = a:value
        return self
    endfunction

    " TODO
    function! builder.set_creation(creation)
        let self.creation = a:creation
        return self
    endfunction

    function! builder.extend_context(context)
        call extend(self.context, a:context)
        return self
    endfunction

    return builder
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set fdm=marker:

