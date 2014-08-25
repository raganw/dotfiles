" System
set nocompatible
set laststatus=2
set encoding=utf-8
filetype off
set shell=/bin/bash
set rtp+=~/.vim/bundle/vundle
set background=dark
call vundle#begin()
Plugin 'gmarik/vundle'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'ctrlp.vim'
Plugin 'scrooloose/syntastic'
call vundle#end()
filetype plugin indent on
syntax on
python from powerline.vim import setup as powerline_setup
python powerline_setup()
python del powerline_setup
command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
set guifont=InconsolataForPowerline-dz:h14
