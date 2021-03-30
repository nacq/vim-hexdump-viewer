"===========================================================
" vim-hexdump-viewer.vim
" Author: Nicolas Acquaviva <nicolaseacquaviva@gmail.com>
"===========================================================

let s:plugin_abs_path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:temp_filename = '/view-hexdump-viewer-file'

function! ViewHexdump(split_pos, current_file)
  " the number of the window that is going to be showing its hex dump
  let g:view_hexdump_win_nr = winnr()

  if a:split_pos == 'v'
    new
  else
    vnew
  endif

  call GenerateHexdump(a:current_file, 0)

  autocmd BufWinEnter * execute "call HandleBufWinEnter()"
endfunction

function! GenerateHexdump(file, is_refresh)
  if a:is_refresh
    let dump_win_nr = GetWindowByBufferName(s:plugin_abs_path . s:temp_filename)
    execute dump_win_nr . 'wincmd w'
  else
    execute 'edit' s:plugin_abs_path . s:temp_filename
  endif

  silent execute '%!cat' a:file
  silent execute '%!xxd'

  " TODO go back to the file
  " execute file_win_nr . 'wincmd w'
endfunction

function! GetWindowByBufferName(buffer_name)
  let bufmap = map(range(1, winnr('$')), '[bufname(winbufnr(v:val)), v:val]')
  " let bufmap = map(range(1, bufnr('$')), '[bufname(winbufnr(v:val)), v:val]')
  let win = filter(bufmap, {i, value -> len(value) > 0 && value[0] =~ a:buffer_name})

  if len(win) > 0
    return win[0][1]
  endif
endfunction

function! HandleBufWinEnter()
  if exists('g:view_hexdump_win_nr') && g:view_hexdump_win_nr == winnr()
    call RefreshHexdump()
  endif
endfunction

function! RefreshHexdump()
  if exists('g:view_hexdump_win_nr')
    call GenerateHexdump(expand('%:p'), 1)
  endif
endfunction

if !exists('g:vim_hexdump_viewer_loaded')
  let g:vim_hexdump_viewer_loaded = 1

  execute "command! VHexdump :call ViewHexdump('v', expand('%:p'))"
  execute "command! HHexdump :call ViewHexdump('h', expand('%:p'))"

  autocmd BufWritePost * execute "call RefreshHexdump()"
endif
