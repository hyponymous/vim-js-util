source $VIMRUNTIME/ftplugin/javascript.vim

nnoremap <buffer>  :call b:VimJsUtil_Tag()<CR>

if exists('g:loaded_vimjsutil') || &cp
  finish
endif
let g:loaded_vimjsutil = 1

function! b:VimJsUtil_Tag()
    let line = getline('.')
    " TODO: pull out the require statement under the cursor
    if match(line, 'require(') >= 0
        let ext = '.js'
        " TODO: parse out the parameter to require without `normal`
        if match(line, "require('jade!") >= 0
            exec "normal |f!lvt'\"zy|"
            let ext = '.jade'
        else
            exec "normal |f'vi'\"zy|"
        endif
        " strip the .js (we'll add it later)
        let requireArg = substitute(getreg('z'), '\.js$', '', '')
        if match(requireArg, './') == 0
            let pattern = substitute(requireArg, '^\.', expand('%:h') . '/**', '') . ext
            let matches = split(glob(pattern), '\n')
        else
            " assume we're using git
            let pattern = '*' . requireArg . ext
            let matches = split(system('git ls-files -- ' . pattern), '\n')
            " fall back on file glob
            if match(matches[0], 'Not a git repository') != -1
                let pattern = '**/' . requireArg . ext
                let matches = split(glob(pattern), '\n')
            endif
        endif
        if len(matches) == 1
            exec ":e " . matches[0]
        elseif len(matches) > 1
            " TODO: show a list (extra credit: order list based on lru and proximity to current file in dir hierarchy)
            " TODO: prefer files that share a prefix with the current file
            exec ":ar " . join(matches, " ")
        else
            echo 'No such file'
        endif
    else
        " TODO: make tern dependency explicit
        TernDef
    endif
endfunction

