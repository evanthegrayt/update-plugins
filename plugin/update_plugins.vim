" update_plugins.vim
" Plugin to update git repo plugins
" Written by Evan Gray
" October 2017

function s:print_list_of_lists(list)
  for [l:msg, l:list] in a:list
    echom l:msg
    if empty(l:list)
      echom ' - None'
    else
      for l:dir in l:list | echom ' - ' . l:dir | endfor
    endif
  endfor
endfunction


function! g:UpdatePlugins()
  if v:version >= 800 && isdirectory($HOME . "/.vim/pack/")
    let l:plugindirs = globpath($HOME, '/.vim/pack/*/start/*/', 0, 1)
  elseif v:version >= 700 && isdirectory($HOME . "/.vim/bundle/")
    let l:plugin_location = $HOME . '/.vim/bundle/'
    let l:plugindirs = split(globpath(l:plugin_location, '*', 0))
  else
    echom "Cound not find a valid plugin directory"
    return
  endif

  call filter(l:plugindirs, 'isdirectory(v:val)')

  let l:success = []
  let l:not_git = []
  let l:uptodate = []

  for l:plugindir in l:plugindirs
    echon "Updating " . l:plugindir . "\r"
    if isdirectory(l:plugindir . '/.git')
      try
        let l:cmd = 'cd ' . l:plugindir . ' && git pull origin master'
        silent! let l:output = system(l:cmd)
        if l:output =~? 'Already up-to-date'
          call add(l:uptodate, l:plugindir)
        else
          call add(l:success, l:plugindir)
        endif
      catch
        echom "Caught exception. Stopping update..."
        return
      endtry
    elseif !isdirectory(l:plugindir . '/.git')
      call add(l:not_git, l:plugindir)
    endif
  endfor

  call s:print_list_of_lists([['Updated:',            l:success],
        \                     ['Already Up-to-date:', l:uptodate],
        \                     ['Not a Git Repo:',     l:not_git]])

endfunction

command! UpdatePlugins call g:UpdatePlugins()


