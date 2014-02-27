source $VIMRUNTIME/ftplugin/javascript.vim

nnoremap <buffer>  :call b:VimJsUtil_Tag()<CR>

if exists('g:loaded_vimjsutil') || &cp
  finish
endif
let g:loaded_vimjsutil = 1

function! b:VimJsUtil_Tag()
    let line = getline('.')
    if match(line, 'require(') >= 0
        exec "normal |f'vi'\"zy|"
        let matches = split(glob('**/' . getreg('z') . '.js'), '\n')
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

