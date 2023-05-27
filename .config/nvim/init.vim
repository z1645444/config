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

autocmd FileType javascript setlocal shiftwidth=2 tabstop=2
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

" <Esc> alternative
"inoremap ii <Esc>

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
Plug 'rust-lang/rust.vim'

Plug 'mattn/emmet-vim'
Plug 'alvan/vim-closetag'
Plug 'prettier/vim-prettier', {
    \ 'do': 'yarn install --frozen-lockfile --production',
    \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'svelte', 'yaml', 'html']}
Plug 'lervag/vimtex'
Plug 'Exafunction/codeium.vim'

" Display
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'Yggdroot/indentLine'
Plug 'morhetz/gruvbox'

call plug#end()


"
" coc.nvim settings
"

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=100

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=number

" " Use <tab> and <S-tab> to navigate completion list:
" inoremap <silent><expr> <TAB>
"             \ pumvisible() ? "\<C-n>" :
"             \ <SID>check_back_space() ? "\<TAB>" :
"             \ coc#refresh()
" inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" " Use <tab> and <S-tab> to navigate completion list: 
" function! CheckBackSpace() abort
"     let col = col('.') - 1
"     return !col || getline('.')[col - 1]  =~ '\s'
" endfunction

" " Insert <tab> when previous text is space, refresh completion if not.
" " <SID>CheckBackSpace()
" inoremap <silent><expr> <TAB>
"             \ coc#pum#visible() ? coc#pum#next(1):
"             \ CheckBackSpace() ? "\<Tab>" :
"             \ coc#refresh()
" inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Use <c-space> to trigger completion:
" inoremap <silent><expr> <c-space> coc#refresh()
inoremap <silent><expr> <c-_> coc#refresh()

" #Use <CR> to confirm completion, use:
" inoremap <expr> <CR> coc#pum#visible() ? coc#_select_confirm() : "\<CR>"

" To make <CR> to confirm selection of selected complete item or notify coc.nvim
" to format on enter, use:
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#_select_confirm()
            \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

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

" Scroll popup documentation
nnoremap <silent><nowait><expr> <C-d> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <silent><nowait><expr> <C-u> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <silent><nowait><expr> <C-d> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <silent><nowait><expr> <C-u> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
vnoremap <silent><nowait><expr> <C-d> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
vnoremap <silent><nowait><expr> <C-u> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"

" Refine messages
set shortmess+=c

" Disable provider
let g:loaded_ruby_provider = 0
let g:loaded_perl_provider = 0

" coc.nvim plugin list
let g:coc_global_extensions = [
    \ 'coc-actions',
    \ 'coc-calc',
    \ 'coc-clangd',
    \ 'coc-css',
    \ 'coc-explorer',
    \ 'coc-highlight',
    \ 'coc-html',
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

" coc-json unable the feature of hidding quotes
set conceallevel=0
let g:vim_json_conceal=0



"
" nvim provider
"
if g:os == 'windows'
    let g:python_host_prog = 'C:\Program Files\Python39\python.exe'
    let g:python3_host_prog = 'C:\Program Files\Python39\python.exe'
elseif g:os == 'unix' || g:os == 'mac'
    let g:python_host_prog = '~/.pyenv/shims/python'
    let g:python3_host_prog = '~/.pyenv/shims/python3'
endif

"
" Codeium
"

" Disable
let g:codeium_enabled = v:false

" Disable for particular filetypes
" let g:codeium_filetypes = {
"         \ "bash": v:false,
"         \ "javascript": v:false,
"         \ "typescript": v:false,
"         \ }

"
" VimTex
"

let g:tex_flavor='latex'
let g:tex_conceal='abdmg'
let maplocalleader = ','

" reader
if g:os == 'unix'
    " let g:vimtex_view_method = 'xdg-open'
    " let g:vimtex_view_method = 'zathura'
elseif g:os == 'windows'
    let g:vimtex_view_general_viewer = 'SumatraPDF'
endif

" compiler
" let g:vimtex_compiler_method = 'latexmk'

