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

if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

filetype plugin indent on
set softtabstop=2
set shiftwidth=2
set tabstop=2
set expandtab

set number
set numberwidth=5

if filereadable(expand("$PYTHONPATH/powerline/bindings/vim/plugin/powerline.vim"))
  source $PYTHONPATH/powerline/bindings/vim/plugin/powerline.vim
endif

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

" Local config
if filereadable($HOME . "/.vimrc.local")
  source ~/.vimrc.local
endif

