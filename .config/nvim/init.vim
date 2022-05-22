"
" Basic settings
"
set nocompatible

filetype on
filetype plugin indent on

set mouse=a
set encoding=utf-8

set number
set relativenumber
set ruler
set cursorline

syntax enable
syntax on

" Tab settings
set expandtab
set softtabstop=4
set shiftwidth=4
set tabstop=4

autocmd FileType python setlocal shiftwidth=2 tabstop=2
autocmd FileType ruby setlocal shiftwidth=2 tabstop=2
autocmd FileType html setlocal shiftwidth=2 tabstop=2
autocmd FileType json setlocal shiftwidth=2 tabstop=2
autocmd FileType toml setlocal shiftwidth=2 tabstop=2
autocmd FileType xml setlocal shiftwidth=2 tabstop=2

set list
set listchars=tab:▸\ ,trail:▫

set scrolloff=5

set splitright
set splitbelow

" Prevent auto line split
set wrap
set tw=0

set indentexpr=

" Better backspace
set backspace=indent,eol,start

set foldmethod=indent
set foldlevel=99

" Prevent incorrect background rendering
let &t_ut=''

let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_SR = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

" Restore Cursor Position
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

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
let g:gruvbox_italic=0
set background=dark
colorscheme gruvbox

"
" Key mapping
"
" Leader Key
let mapleader = "\<space>"

" If there is any unknown error with yanking to system's clipboard on linux
" try use this after installing xclip
"vnoremap Y :w !xclip -i -sel c<CR>

" Copy to system clipboard
vnoremap <leader>y "+y

" Paste from system clipboard
vnoremap <leader>p "+p
nnoremap <leader>p "+p

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

" Edit vimrc file
nnoremap <leader>rc :e ~/.config/nvim/init.vim<CR>
"nnoremap <leader>rc :e C:/Users/1337/AppData/Local/nvim/init.vim<CR>

" Nerdtree
nnoremap <leader>tt :NERDTree<CR>
nnoremap <leader>tf :NERDTreeFocus<CR>
nnoremap <leader>tg :NERDTreeToggle<CR>
nnoremap <leader>tf :NERDTreeFind<CR>

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" use <tab> to explore trigger completion
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" use <c-space> for trigger completion and navigate to the next complete item
inoremap <silent><expr> <c-space> coc#refresh()

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> <leader>[ <Plug>(coc-diagnostic-prev)
nmap <silent> <leader>] <Plug>(coc-diagnostic-next)

" inside {}
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
            \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

"
" Plugin
"
"call plug#begin('C:/VimPlugin')
call plug#begin(stdpath('data').'/plugged')

" Tools
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-surround'
Plug 'preservim/nerdtree'
Plug 'rust-lang/rust.vim'
Plug 'preservim/vim-markdown'


" Display
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

call plug#end()

"
" coc.nvim settings
"
set updatetime=100
set shortmess+=c
set signcolumn=number

let g:loaded_ruby_provider = 0
let g:loaded_perl_provider = 0

" coc.nvim plugin list
let g:coc_global_extensions = [
    \ 'coc-actions',
    \ 'coc-calc',
    \ 'coc-explorer',
    \ 'coc-go',
    \ 'coc-highlight',
    \ 'coc-html',
    \ 'coc-htmldjango',
    \ 'coc-jedi',
    \ 'coc-json',
    \ 'coc-pairs',
    \ 'coc-pyright',
    \ 'coc-rust-analyzer',
    \ 'coc-sh',
    \ 'coc-sql',
    \ 'coc-toml',
    \ 'coc-tsserver',
    \ 'coc-yaml',
    \ ]

"
" nvim provider
"
let g:python_host_prog = '/usr/bin/python'
let g:python3_host_prog = '/usr/bin/python3'

