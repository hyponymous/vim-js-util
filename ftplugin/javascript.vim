source $VIMRUNTIME/ftplugin/javascript.vim

nnoremap <buffer>  :call b:VimJsUtil_Tag()<CR>

if exists('g:loaded_vimjsutil') || &cp
  finish
endif
let g:loaded_vimjsutil = 1

function! b:VimJsUtil_Tag()
    let lastReg = getreg('')
    let zReg = getreg('z')

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
        let matches = []
        " strip the .js (we'll add it later)
        let requireArg = substitute(getreg('z'), '\.js$', '', '')
        " use exact matching for relative paths
        if match(requireArg, '\(\.\./\)\+') == 0 || match(requireArg, '\./') == 0
            let pattern = simplify(expand('%:h') . '/' . requireArg)
            if filereadable(pattern . ext)
                let matches = [pattern . ext]
            elseif filereadable(pattern . '/index.js')
                let matches = [pattern . '/index.js']
            endif
        else
            let pattern = '*' . requireArg . ext
            " try both git ls-files and git status
            " - git ls-files won't pick up untracked files
            " - git status won't pick up unchanged files
            let matches = split(system('git ls-files -- ' . pattern), '\n')
            if len(matches) == 0 || match(matches[0], 'Not a git repository') != -1
                let matches = split(system('git status --porcelain -- ' . pattern . ' | sed -e "s/^.. //"'), '\n')
            endif
            " fall back on file glob
            if len(matches) == 0 || match(matches[0], 'Not a git repository') != -1
                let pattern = '**/' . requireArg . ext
                let matches = split(glob(pattern), '\n')
            endif
        endif
        if len(matches) == 1
            exec ":e " . simplify(matches[0])
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

    call setreg('', lastReg)
    call setreg('z', zReg)
endfunction

