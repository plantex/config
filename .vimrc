set nocompatible

filetype plugin indent on

set autoread
set autowrite

syntax on

set number
set relativenumber
set backspace=indent,eol,start
set expandtab
set softtabstop=4
set shiftwidth=4
set autoindent

if version >= 703
    " set colorcolumn=+1
    set undofile
    set undodir=~/.vimtmp/undo
    silent !mkdir -p ~/.vimtmp/undo
endif
"set textwidth=80

set scrolloff=5

set cursorline
match Error "\s\+$"

set mouse=a

set completeopt=menu,longest

set visualbell

" Highlight over lenght
colorscheme slate
set background=dark
highlight OverLength ctermbg=darkred ctermfg=white guibg=#592929
match OverLength /\%81v.*/
