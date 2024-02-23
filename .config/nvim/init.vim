" Welcome to my small nvim configuration
" Install Plugins using vim-plugs :PlugInstall
"------------------------------------------------------------------------------
" TODO :
" - substitute plugins
"    - configure own status/tab bar instead of airline
"    - write own functions around fzf wrapper and get rid of fzf.vim
"       - mainly interesting are :rg and :Files
" - 'set hidden' to switch between buffers without saving ? autocommand groups : sounds like I need them
"------------------------------------------------------------------------------
" SETTINGS

" set (local to buffer) leader key
let mapleader='\'
let maolocalleader=mapleader

" disable vi compatibility
set nocompatible

" enable detection of filetypes
filetype on

" enable and load plugins for detected filetype
filetype plugin on

" load indent file for detected filetype
filetype indent on

" syntax highlighting
syntax on

" line numbers
set number
"set relativenumber

" highlight cursor horizontal
set cursorline

" highlight cursor vertical
" set cursorcolumn

" shift width to 4 spaces
set shiftwidth=4

" tab width to 4 spaces
set tabstop=4

" use spaces instead of tabs
set expandtab

" no line wrapping
set nowrap

" when searching through files, highlight matches incrementally
set incsearch

" show effects of substitute etc. without modifying buffer
" use split to show off-screen results in preview window
set inccommand=split

" case insensitive search
set ignorecase

" override case insensitivity when searching with uppercase letters
set smartcase

" show partial commands you type in last line
set showcmd

" show current mode in last line
set showmode

" show matching word during search
set showmatch

" use highlighting when searching
set hlsearch

" set command history size (default 20)
set history=100

" vertical line border at column 80
set cc=80
highlight ColorColumn ctermbg=0 guibg=darkred

" use system clipboard
set clipboard=unnamedplus

" command autocompletion
set wildmenu
set wildmode=longest,list,full " docs : :h 'wildmode'
set completeopt-=preview

" on error don't beep but blink cursor
set visualbell

" spell checking
setlocal spell spelllang=en_us,de_de

" reread file when changed from the outside
set autoread

" enable termguicolors
set termguicolors

" vertical block selection (even if on another line that col has not been
" reached)
set ve=block


"------------------------------------------------------------------------------
" AUTOCMDS
"

" start page
au VimEnter * if @% == "" | Explore! | endif 

" when reopening a file jump to last position
au BufReadPost * if line("'\"") > 0 && line ("'\"") <= line("$")
  \| exe "normal! g'\"" | endif                                 

" disable line numbering in terminal mode
au TermOpen * set nonumber norelativenumber

" auto format on write
augroup AutoFormat
    autocmd!
    " Apply auto-format only for non-Go files
    autocmd BufWritePre * if &filetype != 'go' | :call CocActionAsync('format') | endif
augroup END

" The following comes from : https://oren.github.io/articles/rust/neovim/

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

"------------------------------------------------------------------------------
" MAPPINGS 

" move between panes to left/bottom/top/right
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

" open file (by placing cusor in front of filename) in vertical split
" handy for i.e. imports
nnoremap gf :vert winc f<cr>

" exit terminal mode using esc
tnoremap <Esc> <C-\><C-n>

" use enter to confirm autocomplete suggestion
inoremap <expr> <CR> pumvisible() ? "\<C-Y>" : "\<CR>"

"------------------------------------------------------------------------------
" PLUGINS

call plug#begin("~/.vim/plugged")
 " tools
 Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } " fuzzy finder
 Plug 'junegunn/fzf.vim'                             " default fzf features

 " Cosmetics/easy tools
 Plug 'dracula/vim'                               " theme
 Plug 'neoclide/coc.nvim', {'branch': 'release'}  " code completion
 Plug 'RRethy/vim-illuminate'                     " highlight other uses
 Plug 'github/copilot.vim'

 " Language specific stuff
 Plug 'fatih/vim-go', {'do': ':GoUpdateBinaries'}
 " Plug 'rust-lang/rust.vim'
call plug#end()

" fzf popup window at bottom (relative to current window)
let g:fzf_layout = { 
    \ 'window': {
       \  'width': 0.9, 
       \  'height': 0.6, 
       \  'relative': v:true, 
       \  'yoffset': 1.0 } } 


" open GoDoc ( by pressing K or :GoDoc) in popup window instead of buffer
" so it can be closed faster
let g:go_doc_popup_window = 1

"------------------------------------------------------------------------------
" COLOR SCHEMES

colorscheme dracula
