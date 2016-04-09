set nocompatible              " be iMproved, required
set encoding=utf-8  " The encoding displayed.
set fileencoding=utf-8  " The encoding written to file.

call plug#begin()

Plug 'scwood/vim-hybrid'
Plug 'easysid/mod8.vim'
Plug 'marcopaganini/termschool-vim-theme'
Plug 'ctrlpvim/ctrlp.vim' " fuzzy file finder, mapped to <leader>t
Plug 'tpope/vim-fugitive' " amazing git wrapper for vim
Plug 'vim-airline/vim-airline' " fancy statusline
Plug 'scrooloose/nerdtree' "NERDTree
Plug 'nanotech/jellybeans.vim'
Plug 'altercation/vim-colors-solarized'
Plug 'vim-airline/vim-airline-themes'

" language-specific plugins
Plug 'mattn/emmet-vim', { 'for': 'html' } " emmet support for vim - easily create markdup wth CSS-like syntax
Plug 'gregsexton/MatchTag', { 'for': 'html' } " match tags in html, similar to paren support
Plug 'othree/html5.vim', { 'for': 'html' } " html5 support
Plug 'pangloss/vim-javascript', { 'for': 'javascript' } " JavaScript support
Plug 'othree/yajs.vim', { 'for': 'javascript' } " JavaScript syntax plugin
Plug 'elzr/vim-json', { 'for': 'json' } " JSON support

Plug 'cakebaker/scss-syntax.vim', { 'for': 'scss' } " sass scss syntax support
Plug 'hail2u/vim-css3-syntax', { 'for': 'css' } " CSS3 syntax support
Plug 'tpope/vim-markdown', { 'for': 'markdown' } " markdown support

call plug#end()


syntax on
set background=dark
colorscheme termschool
let g:airline_theme='wombat'

let g:airline_powerline_fonts = 1
let g:airline_symbols = {}

" unicode symbols
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.whitespace = 'Ξ'

" airline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''


set timeoutlen=3000                              "tm:    time in ms waiting for a key mapping sequence to complete
set ttimeoutlen=100                              "ttm:   time out on key codes after a tenth of a second
set history=50                                   "hi:    keep 50 lines of command line history
set ruler                                        "ru:    show the cursor position all the time
set showcmd                                      "sc:    display incomplete commands
set hidden                                       "hid:   don't care about closing modified buffers
set winwidth=84                                  "       The window width with multiple windows
set mouse=a                                      "       Enable the use of a mouse
set nowrap                                       "       don't wrap lines (mapped leader-w to toggle)
set t_Co=256                                     "       set iTerm terminal to 256 colors
set backspace=indent,eol,start                   "       Behave like a normal text editor
set noshowmode                                   "nosmd: Status-line shows the mode we're in
set showbreak=\ ↪︎\                               "sbr:   Show Unicode 21AA (RIGHTWARDS ARROW WITH HOOK) surrounded by spaces when soft-wrapping lines
set nobackup                                     "       Don't write backup files
set nowritebackup
set noswapfile
set cmdwinheight=20                                " Height of command window
set cursorline
