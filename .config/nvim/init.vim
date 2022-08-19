"
" Detect system
"
if !exists('g:os')
    if has('win64') || has('win32') || has('win16')
        let g:os = "windows"
    elseif has('unix')
        let g:os = "unix"
    elseif has('mac')
        let g:os = "mac"
    endif
endif

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

" EOL format
set fileformat=unix


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

" Reload
nnoremap <leader>rl :source %<CR>

" Quickly Run
map <F5> :call CompileAndRun()<CR>
if g:os == 'windows'
    func! CompileAndRun()
        exec "w"
        if &filetype == 'c'
            exec "!gcc % -o %<"
        elseif &filetype == 'cpp'
            exec "!g++ % -o %<"
        elseif &filetype == 'java'
            exec "!javac %"
        elseif &filetype == 'python'
            exec "!python %"
        elseif &filetype == 'go'
            exec "!go run %"
        endif
    endfunc
elseif g:os == 'unix' || g:os == 'mac'
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
            exec ":!time bash %"
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
endif

" Scroll
nnoremap <leader>h 10h
nnoremap <leader>j 10j
nnoremap <leader>k 10k
nnoremap <leader>l 10l

" Edit vimrc file
if g:os == 'windows'
    nnoremap <expr> <leader>rc ':e '.stdpath('config').'\init.vim<CR>'
elseif g:os == 'unix' || g:os == 'mac'
    nnoremap <expr> <leader>rc ':e '.stdpath('config').'/init.vim<CR>'
endif

" Nerdtree
nnoremap <leader>tt :NERDTree<CR>
nnoremap <leader>tf :NERDTreeFocus<CR>
nnoremap <leader>tg :NERDTreeToggle<CR>
nnoremap <leader>tf :NERDTreeFind<CR>

"
" coc.nvim part
"

" Use tab for trigger completion with characters ahead and navigate.
inoremap <silent><expr> <TAB>
\ coc#pum#visible() ? coc#pum#next(1):
\ <SID>check_back_space() ? "\<Tab>" :
\ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> <leader>[ <Plug>(coc-diagnostic-prev)
nmap <silent> <leader>] <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Navigate completion list
function! s:check_back_space() abort
let col = col('.') - 1
return !col || getline('.')[col - 1]  =~ '\s'
endfunction


"
" Plugin
"
call plug#begin(stdpath('data').'/plugged')

" Basic
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'preservim/nerdtree'
Plug 'terryma/vim-multiple-cursors'


" Language basic
Plug 'preservim/vim-markdown'
Plug 'jbgutierrez/vim-better-comments'
Plug 'rust-lang/rust.vim'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" Plug 'ray-x/go.nvim'

Plug 'mattn/emmet-vim'
Plug 'alvan/vim-closetag'
Plug 'prettier/vim-prettier', {
    \ 'do': 'yarn install --frozen-lockfile --production',
    \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'svelte', 'yaml', 'html']}


" Display
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'Yggdroot/indentLine'
Plug 'morhetz/gruvbox'

call plug#end()

" vim-go settings
let g:deoplete#enable_at_startup = 1
call deoplete#custom#option('omni_patterns', { 'go': '[^. *\t]\.\w*' })

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
    \ 'coc-css',
    \ 'coc-explorer',
    \ 'coc-highlight',
    \ 'coc-html',
    \ 'coc-htmldjango',
    \ 'coc-jedi',
    \ 'coc-json',
    \ 'coc-pairs',
    \ 'coc-pyright',
    \ 'coc-rust-analyzer',
    \ 'coc-sh',
    \ 'coc-toml',
    \ 'coc-tsserver',
    \ 'coc-vimlsp',
    \ 'coc-yaml',
    \ ]

" coc-pairs disable for specified filetypes
autocmd FileType markdown let b:coc_pairs_disabled = ['`']
autocmd FileType html let b:coc_pairs_disabled = ['<']
autocmd FileType xml let b:coc_pairs_disabled = ['<']


"
" nvim provider
"
if g:os == 'windows'
    let g:python_host_prog = 'C:\Program Files\Python39\python.exe'
    let g:python3_host_prog = 'C:\Program Files\Python39\python.exe'
elseif g:os == 'unix' || g:os == 'mac'
    let g:python_host_prog = '/usr/bin/python'
    let g:python3_host_prog = '/usr/bin/python3'
endif

