" System
set nocompatible
set laststatus=2
set encoding=utf-8
filetype off
set shell=/bin/bash
set rtp+=~/.vim/bundle/vundle
call vundle#begin()
Plugin 'gmarik/vundle'
Plugin 'tpope/vim-fugitive'
Plugin 'ctrlp.vim'
Plugin 'scrooloose/syntastic'
call vundle#end()
filetype plugin indent on
syntax on
" python from powerline.vim import setup as powerline_setup
" python powerline_setup()
" python del powerline_setup
