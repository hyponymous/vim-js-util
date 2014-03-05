source $VIMRUNTIME/ftplugin/javascript.vim

nnoremap <buffer>  :call b:VimJsUtil_Tag()<CR>

if exists('g:loaded_vimjsutil') || &cp
  finish
endif
let g:loaded_vimjsutil = 1

function! b:VimJsUtil_Tag()
    let line = getline('.')
    if match(line, 'require(') >= 0
        let ext = '.js'
        if match(line, "require('jade!") >= 0
            exec "normal |f!lvt'\"zy|"
            let ext = '.jade'
        else
            exec "normal |f'vi'\"zy|"
        endif
        let matches = split(glob('**/' . getreg('z') . ext), '\n')
        if len(matches) == 1
            exec ":e " . matches[0]
        elseif len(matches) > 1
            " TODO: show a list (extra credit: order list based on lru and proximity to current file in dir hierarchy)
            exec ":ar " . join(matches, " ")
        else
            echo 'No such file'
        endif
    else
        " TODO: make tern dependency explicit
        TernDef
    endif
endfunction

