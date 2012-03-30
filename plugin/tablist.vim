function! s:bufname(nr)
  let name = bufname(a:nr)
  if len(name) > 0
	 if name =~ '[\\/]'
       return fnamemodify(name, ':p:t')
     else
       return name
     endif
  else
    return "*"
  endif
endfunction

function! s:close()
  if bufexists('__TABLIST__')
    execute bufwinnr('__TABLIST__').'wincmd w'
	bw!
  endif
endfunction

function! s:open()
  let i = b:tablist[line('.')-1]
  call s:close()
  if len(i) == 1
    exe "tabnext" i[0]
  else
    exe "tabnext" i[0]
    exe bufwinnr(i[1]).'wincmd w'
  endif
endfunction

function! s:tablist()
  call s:close()
  let lines = []
  let info = []
  for t in map(range(1, tabpagenr('$')), '{ "nr": v:val, "buflist": map(tabpagebuflist(v:val), ''{ "nr": v:val, "name": s:bufname(v:val) }'') }')
    call add(info, [t.nr])
    call add(lines, printf("Tab%d", t.nr))
    for b in t.buflist
      call add(info, [t.nr, b.nr])
      call add(lines, printf("  %s", b.name))
    endfor
  endfor
  exe "silent" "topleft" get(g:, 'tablist_width', 15) "vsp" "__TABLIST__"
  call setline(1, lines)
  setlocal buftype=nofile bufhidden=wipe cursorline
  nnoremap <buffer> <silent> <cr> :call <SID>open()<cr>
  nnoremap <buffer> <silent> q :call <SID>close()<cr>
  let b:tablist = info
endfunction

command! TabList call s:tablist()
nnoremap <silent> <plug>(tablist) :<c-u>TabList<cr>
if get(g:, 'tablist_no_default_key_mappings', 0) == 0
  silent! map <unique> <leader>T <plug>(tablist)
endif
