" ====================
" === Editor Setup ===
" ====================

" ===
" === System
" ===
set nocompatible
filetype on
" !!filetype indent on
" !!filetype plugin on
filetype plugin indent on
set mouse=a
set encoding=utf-8

" ===
" === Multi Platforms
" ===
if has("gui_running")
  if has("gui_gtk3")
    set guifont=fira_code\ 12
  elseif has("gui_macvim")
    set guifont=menlo\ regular:h12
  elseif has("gui_win32")
    set guifont=fira_code:h12:cANSI
    set guifontwide=幼圆:h12
    "set guifontwide=思源黑体:h12
  endif
endif

"set clipboard=unnamed

" Prevent incorrect backgroung rendering
let &t_ut=''

" ===
" === Main code display
" ===
set number
set relativenumber
set ruler
set cursorline
syntax enable
syntax on

" ===
" === Editor behavior
" ===
" Better tab
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set list
set listchars=tab:▸\ ,trail:▫
set scrolloff=5

" Prevent auto line split
set wrap
set tw=0

set indentexpr=

" Better backspace
set backspace=indent,eol,start

set foldmethod=indent
set foldlevel=99

let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_SR = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

" Restore Cursor Position
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" ===
" === Window behaviors
" ===
set splitright
set splitbelow

" ===
" === Status/command bar
" ===
set laststatus=2
set autochdir
set showcmd
set formatoptions-=tc

" Show command autocomplete
set wildignore=log/**,node_modules/**,target/**,tmp/**,*.rbc
set wildmenu

" show a navigable menu for tab completion
set wildmode=longest,list,full

" Searching options
set hlsearch
exec "nohlsearch"
set incsearch
set ignorecase
set smartcase

" Color Scheme
set termguicolors
colorscheme gruvbox
let g:gruvbox_italicize_comments=0

" ===
" === Hotkey setting
" ===

" Leader Key
let mapleader = "\<space>"

" Copy to system clipboard
" on Linux
"vnoremap Y :w !xclip -i -sel c<CR>

" Copy to system clipboard
vnoremap <leader>y "+y

" Split Windows
nnoremap <leader>sp :split<CR>
nnoremap <leader>vp :vsplit<CR>

" Quickly Run
map <F5> :call CompileAndRun()<CR>
func! CompileAndRun()
    exec "w"
    if &filetype == 'c'
        exec "!g++ % -o %<"
        exec "!time ./%<"
    elseif &filetype == 'cpp'
        exec "!g++ % -o %<"
        exec "!time ./%<"
    elseif &filetype == 'java'
        exec "!javac %"
        exec "!time java %<"
    elseif &filetype == 'sh'
        :!time bash %
    elseif &filetype == 'python'
        exec "!time python %"
    elseif &filetype == 'html'
        exec "!firefox % &"
    elseif &filetype == 'go'
"        exec "!go build %<"
        exec "!time go run %"
    elseif &filetype == 'mkd'
        exec "!~/.vim/markdown.pl % > %.html &"
        exec "!firefox %.html &"
    endif
endfunc

" Scroll
nnoremap <leader>h 10h
nnoremap <leader>j 10j
nnoremap <leader>k 10k
nnoremap <leader>l 10l

" Markdown
nnoremap <leader>md :CocCommand markdown-preview-enhanced.openPreview<CR>

" Edit vimrc file
"nnoremap <leader>rc :e ~/.vimrc<CR>
nnoremap <leader>rc :e C:/Program Files/Vim/_vimrc<CR>

" Nerdtree
nnoremap <leader>tt :NERDTree<CR>
nnoremap <leader>tf :NERDTreeFocus<CR>
nnoremap <leader>tg :NERDTreeToggle<CR>
nnoremap <leader>tf :NERDTreeFind<CR>

"call plug#begin('~/.vim/plugged')
call plug#begin('D:/VimPlugin')

" Tools
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-surround'
Plug 'preservim/nerdtree'
Plug 'rust-lang/rust.vim'

" Display
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

call plug#end()

" use <tab> for trigger completion and navigate to the next complete item
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction"

