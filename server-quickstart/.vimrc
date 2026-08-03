set number
set relativenumber

set tabstop=2
set shiftwidth=2
set softtabstop=2

let mapleader = " "
let maplocalleader = " "

function! s:OSC52Copy(text) abort
  let l:encoded = system('base64 | tr -d "\r\n"', a:text)

  if !empty($TMUX)
    " tmux
    let l:osc52 = "\ePtmux;\e\e]52;c;" . l:encoded . "\x07\e\\"
  elseif $TERM =~# '^screen'
    " GNU Screen
    let l:osc52 = "\eP\e]52;c;" . l:encoded . "\x07\e\\"
  else
    " normal terminal
    let l:osc52 = "\e]52;c;" . l:encoded . "\x07"
  endif

  if writefile([l:osc52], '/dev/tty', 'b') == -1
    call system('printf %s ' . shellescape(l:osc52) . ' > /dev/tty')
  endif
endfunction

" Visual mode
function! s:OSC52YankVisual() abort
  let l:saved_reg = @@
  normal! gvy
  let l:text = @@
  let @@ = l:saved_reg
  call s:OSC52Copy(l:text)
endfunction

" Normal mode Operator
function! s:OSC52YankOperator(type) abort
  let l:saved_reg = @@
  if a:type ==# 'line'
    silent normal! '[V']y
  elseif a:type ==# 'char'
    silent normal! `[v`]y
  else
    return
  endif
  let l:text = @@
  let @@ = l:saved_reg
  call s:OSC52Copy(l:text)
endfunction

vnoremap <silent> <leader>Y :<C-u>call <SID>OSC52YankVisual()<CR>
nnoremap <silent> <leader>Y :set operatorfunc=<SID>OSC52YankOperator<CR>g@
