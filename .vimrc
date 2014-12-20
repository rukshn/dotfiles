set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
Plugin 'sickill/vim-monokai'
Plugin 'scrooloose/nerdtree'
Plugin 'Shougo/neocomplcache.vim'
Plugin 'hail2u/vim-css3-syntax'
Plugin 'Yggdroot/indentLine'
Plugin 'mattn/emmet-vim'
Plugin 'nanotech/jellybeans.vim'
Plugin 'sickill/vim-sunburst'
Plugin 'blerins/flattown'
Plugin 'ajh17/Spacegray.vim'
Plugin 'Raimondi/delimitMate'
Plugin 'whatyouhide/vim-gotham'
Plugin 'cocopon/iceberg.vim'
Plugin 'gosukiwi/vim-atom-dark'
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
"
"END OF VUNDLE
"
set t_Co=256
set background=dark
colorscheme atom-dark-256 
set encoding=utf-8

:nnoremap <expr> y (v:register ==# '"' ? '"+' : '') . 'y'
:nnoremap <expr> yy (v:register ==# '"' ? '"+' : '') . 'yy'
:nnoremap <expr> Y (v:register ==# '"' ? '"+' : '') . 'Y'
:xnoremap <expr> y (v:register ==# '"' ? '"+' : '') . 'y'
:xnoremap <expr> Y (v:register ==# '"' ? '"+' : '') . 'Y'

" Easy navigation between splits. Instead of ctrl-w + j. Just ctrl-j
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

nmap <C-N> :set invnumber<CR>
nmap <C-V> :set paste<CR>
nmap <C-V><C-V> :set nopaste<CR>

" Toggle nerdtree with F10
map <F10> :NERDTreeToggle<CR>
" Current file in nerdtree
map <F9> :NERDTreeFind<CR>

set backspace=2   " Backspace deletes like most programs in insert mode
set nocompatible  " Use Vim settings, rather then Vi settings
set nobackup
set nowritebackup
set noswapfile    " http://robots.thoughtbot.com/post/18739402579/global-gitignore#comment-458413287
set history=500
set ruler         " show the cursor position all the time
set showcmd       " display incomplete commands
set incsearch     " do incremental searching
set hlsearch      " highlight matches
set laststatus=2  " Always display the status line
set autowrite     " Automatically :write before running commands

" bind K to search word under cursor
nnoremap K :Ag "\b<C-R><C-W>\b"<CR>:cw<CR>

" Softtabs, 2 spaces
set tabstop=2
set shiftwidth=2
set expandtab


" Highlight line number of where cursor currently is
hi CursorLineNr guifg=#050505


"Neo Complete"
let g:neocomplcache_enable_at_startup = 1

"Indent Guides"
let g:indent_guides_enable_on_vim_startup = 1
let g:indentLine_color_term = 239
