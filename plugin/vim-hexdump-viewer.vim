"===========================================================
"" vim-hexdump-viewer.vim
" Author: Nicolas Acquaviva <nicolaseacquaviva@gmail.com>
"===========================================================

let s:plugin_path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:temp_filename = '/view-hexdump-viewer-file'

function! ViewHexdump(split_pos, current_file)
  if a:split_pos == 'v'
    new
  else
    vnew
  endif

  let g:view_hexdump_opened = 1

  call GenerateHexdump(a:current_file)
endfunction

function! GenerateHexdump(file)
  execute 'edit' s:plugin_path . s:temp_filename
  execute '%!cat' a:file
  execute '%!xxd'
endfunction

function! RefreshHexdump()
  if exists('g:view_hexdump_opened')
    let tmp_buffer = bufnr(s:plugin_path . '')
    call GenerateHexdump(expand('%:p'))
  endif
endfunction

if !exists('g:vim_hexdump_viewer_loaded')
  let g:vim_hexdump_viewer_loaded = 1

  execute "command! VHexdump :call ViewHexdump('v', expand('%:p'))"
  execute "command! HHexdump :call ViewHexdump('h', expand('%:p'))"

  autocmd BufWritePost *.vim execute "call RefreshHexdump()"
endif
