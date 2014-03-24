" System
set nocompatible
set laststatus=2
set encoding=utf-8
filetype off
set shell=/bin/bash
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'
Bundle 'tpope/vim-fugitive'
Bundle 'ctrlp.vim'
python from powerline.vim import setup as powerline_setup
python powerline_setup()
python del powerline_setup
