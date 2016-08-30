" System
set nocompatible

let mapleader = ","

set nobackup
set nowritebackup
set noswapfile
set history=50
set ruler
set showcmd
set incsearch
set autowrite
set laststatus=2 " Always display the statusline in all windows
set showtabline=2 " Always display the tabline, even if there is only one tab
set noshowmode " Hide the default mode text (e.g. -- INSERT -- below the statusline)
set encoding=utf-8
set shell=/usr/local/bin/zsh
set background=dark

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
  syntax on
endif

filetype plugin indent on
set softtabstop=2
set shiftwidth=2
set tabstop=2
set expandtab

set number
set numberwidth=5

command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
set guifont=InconsolataForPowerline-dz:h14


" Create directional shortcuts for moving among between splits
nmap <C-j> <C-W>j
nmap <C-k> <C-W>k
nmap <C-l> <C-W>l
nmap <C-h> <C-W>h

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Easier window resizing
if bufwinnr(1)
  map + <C-W>+
  map - <C-W>-
end

" Syntastic
let g:syntastic_enable_signs = 1
let g:syntastic_quiet_messages = {'level': 'warnings'}
let g:syntastic_auto_loc_list = 2

set ttyfast

set mouse=a

set ttymouse=xterm

augroup vimrcEx
  autocmd!

  " automatically remove trailing whitespace before write
  function! StripTrailingWhitespace()
    normal mZ
    %s/\s\+$//e
    if line("'Z") != line(".")
      echo "Stripped whitespace\n"
    endif
    normal `Z
  endfunction
  autocmd BufWritePre *.bldr,*.md,*.coffee,*.rake,*.js,*.rb,*.css,*.sass,*.scss,*.haml,*.erb,*.cpp,*.hpp,*.i :call StripTrailingWhitespace()

  " hint to keep lines short
  if exists('+colorcolumn')
    set colorcolumn=80
  else
    au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
  endif

augroup END

set grepprg=ack

" Local config
if filereadable($HOME . "/.vimrc.local")
  source ~/.vimrc.local
endif

set clipboard=unnamed
" Plugins {{{

if empty(glob('~/.vim/autoload/plug.vim'))
  !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

let g:airline_powerline_fonts = 1
let g:tmuxline_theme = 'nightly_fox'
let g:tmuxline_preset = 'nightly_fox'

call plug#begin('~/.vim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'edkolev/promptline.vim', { 'on': 'PromptlineSnapshot' }
" Plug 'edkolev/tmuxline.vim', { 'on': 'Tmuxline' }
" Plug 'adambiggs/tmuxline.vim', { 'on': 'Tmuxline' }
" Define bundles via Github repos
" Plug 'cakebaker/scss-syntax.vim'
" Plug 'danro/rename.vim'
" Plug 'kchmck/vim-coffee-script'
" Plug 'kien/ctrlp.vim'
" Plug 'majutsushi/tagbar'
" Plug 'mattn/gist-vim'
" Plug 'mattn/webapi-vim'
" Plug 'millermedeiros/vim-statline'
" Plug 'mustache/vim-mustache-handlebars'
" Plug 'nanotech/jellybeans.vim'
" Plug 'pangloss/vim-javascript'
" Plug 'rizzatti/dash.vim'
" Plug 'scrooloose/nerdcommenter'
" Plug 'scrooloose/nerdtree'
" Plug 'scrooloose/syntastic'
" Plug 'thoughtbot/vim-rspec'
" Plug 'tpope/vim-bundler'
" Plug 'tpope/vim-cucumber'
" Plug 'tpope/vim-dispatch'
" Plug 'tpope/vim-endwise'
" Plug 'tpope/vim-fireplace'
" Plug 'tpope/vim-fugitive'
" Plug 'tpope/vim-classpath'
" Plug 'tpope/vim-git'
" Plug 'tpope/vim-haml'
" Plug 'tpope/vim-markdown'
" Plug 'tpope/vim-rails'
" Plug 'tpope/vim-surround'
" Plug 'tpope/vim-unimpaired'
" Plug 'vim-ruby/vim-ruby'
" Plug 'vim-scripts/YankRing.vim'
" Plug 'vim-scripts/bufexplorer.zip'
" Plug 'vim-scripts/csv.vim'
" Plug 'vim-scripts/ctags.vim'
" Plug 'snipmate'
" Plug 'tComment'
" Plug 'paredit.vim'
call plug#end()

" }}}
