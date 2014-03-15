" System
set nocompatible
set laststatus=2
set encoding=utf-8
let g:Powerline_symbols = 'fancy'
filetype off
set shell=/bin/bash
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'
Bundle 'tpope/vim-fugitive'
Bundle 'ctrlp.vim'
Bundle 'Lokaltog/vim-powerline'
