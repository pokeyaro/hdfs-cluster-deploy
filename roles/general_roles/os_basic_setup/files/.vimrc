" Vim configuration file
" Maintained by: Pokeya

" Avoid potential security vulnerability related to modeline
set modelines=0                   " CVE-2007-2438

" Use Vim's own defaults instead of 100% vi compatibility
set nocompatible

" Powerful backspacing
set backspace=2

" Do not load default settings in /etc/vim/vimrc or $VIM/vimrc
let skip_defaults_vim=1

" Enable syntax highlighting
syntax on

" Display line numbers
set nu

" Set the tabulation length to 4
set tabstop=4

" Do not create a backup when overwriting files
set nobackup

" Highlight the current line
set cursorline

" Enable high lighting for search results
set hlsearch

" Display the current mode in the bottom-left corner
set showmode

" Set a 256 color mode for vim inside terminal emulators like konsole or gnome-terminal
set t_Co=256

" Use different tones of colors for background
set bg=dark

" Display the cursor's position in the bottom-right corner
set ruler

" Enable auto-indenting
set autoindent

" Enable paste mode
set paste

" Set encodings
set encoding=utf-8
set termencoding=utf-8
set fileencoding=chinese
set fileencodings=ucs-bom,utf-8,chinese
set langmenu=zh_CN,utf-8
