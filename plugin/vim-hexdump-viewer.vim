"===========================================================
" vim-hexdump-viewer.vim
" Author: Nicolas Acquaviva <nicolaseacquaviva@gmail.com>
"===========================================================

let s:plugin_path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
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
endfunction

function! GenerateHexdump(file, is_refresh)
  let dump_win_nr = GetWindowByBufferName(s:plugin_path . s:temp_filename)

  if a:is_refresh
    execute dump_win_nr . 'wincmd w'
  else
    execute 'edit' s:plugin_path . s:temp_filename
  endif

  execute '%!cat' a:file
  execute '%!xxd'
endfunction

function! GetWindowByBufferName(buffer_name)
  let bufmap = map(range(1, winnr('$')), '[bufname(winbufnr(v:val)), v:val]')
  let win = filter(bufmap, 'v:val[0] =~ a:buffer_name')[0][1]

  return win
endfunction

function! HandleBufEnter()
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

  autocmd BufWritePost *.vim execute "call RefreshHexdump()"
  autocmd BufEnter *.vim execute "call HandleBufEnter()"
endif
