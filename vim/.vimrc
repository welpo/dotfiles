" Features {{{1
set nocompatible
syntax enable

colorscheme hipster

" Install vim-plug
let data_dir = '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Use vim-plug
call plug#begin('~/.vim/plugged')

Plug 'easymotion/vim-easymotion'
Plug 'nvie/vim-flake8'
Plug 'christoomey/vim-tmux-navigator'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-surround'

" Initialize plugin system
call plug#end()

" Must have options {{{1
set wildmenu
set hlsearch
set showcmd

" Usability options {{{1
" Edit crontab in-place
autocmd FileType crontab setlocal nowritebackup

" Disable automatic use of clipboard on visual selection
set mouse=a
set autoread
set backspace=2
set breakindent
set clipboard=exclude:.*
set confirm
set encoding=utf-8
set expandtab
set expandtab
set fileencodings=utf-8
set fileformats=unix,dos,mac
set foldmethod=marker
set hidden
set history=1000
set ignorecase
set incsearch
set laststatus=2
set list
set listchars=tab:▸\ ,eol:¬
set listchars+=nbsp:!
set notimeout ttimeout ttimeoutlen=600
set number
set ruler
set shiftwidth=4
set smartcase
set smartindent
set spelllang=eng
set t_vb=
set tabstop=4
set ttyfast
set undolevels=1000
set visualbell
set wildmode=list:longest,list:full
set wrap
set wrapmargin=0

" Create backup, swap and undo directories if they don't exist
if !isdirectory(expand('~/.vim/backup'))
    silent! execute '!mkdir -p ~/.vim/backup'
endif

if !isdirectory(expand('~/.vim/swap'))
    silent! execute '!mkdir -p ~/.vim/swap'
endif

if !isdirectory(expand('~/.vim/undo'))
    silent! execute '!mkdir -p ~/.vim/undo'
endif

" Set backup, swap and undo directories
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set undodir=~/.vim/undo//

" Mappings {{{1
noremap <F1> <Esc>
nnoremap <C-P> :w<CR>:!/usr/bin/env python %<CR>

" Reselect visual selections when indenting
vnoremap < <gv
vnoremap > >gv

" Improve up/down on wrapped lines
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

" Clear highlight from search
nnoremap <C-L> :nohl<CR><C-L>

" Move current line up/down
nnoremap <A-j> :m-2<CR>==
nnoremap <A-k> :m+<CR>==

" Invert paste mode setting
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
set showmode
au InsertLeave * set nopaste

" Typos
iabbr ture true
iabbr flase false
iabbr teh the
iabbr taht that
iabbr esle else
iabbr lien line
iabbr dierctory directory
iabbr tshi this
iabbr hte the

" Leaders {{{1
let mapleader = "\<Space>"
nnoremap <leader>. :cd %:h<CR>
" copy to attached terminal using the yank(1) script:
" https://github.com/sunaku/home/blob/master/bin/yank
nnoremap <silent> <leader>c y:call system('yank', @0)<CR>
vnoremap <silent> <leader>c y:call system('yank', @0)<CR>
nnoremap <silent> <leader>a y:echon system('nani', @0)<CR>
vnoremap <silent> <leader>a y:echon system('nani', @0)<CR>
nnoremap <leader>e :Errors<CR>
nnoremap <leader>n <C-W>n<C-W><C-W>
nnoremap <leader>p :w<CR>:!/usr/bin/env python %<CR>
nnoremap <leader>q :q<cr>
vnoremap <leader>s :sort<CR>
nnoremap <leader>v <C-W>v<C-W><C-W>
nnoremap <leader>w :write<CR>
nnoremap <leader>z :wq!<CR>

" Autocommands {{{1
" Highlight trailing whitespace " {{{2
highlight ExtraWhitespace guibg=#bd5353 ctermbg=131
augroup whitespace
    au!
    au ColorScheme * highlight ExtraWhitespace guibg=#bd5353 ctermbg=131
    au BufWinEnter * match ExtraWhitespace /\s\+$\| \+\ze\t/
    au BufWrite * match ExtraWhitespace /\s\+$\| \+\ze\t/
augroup end

" Functions {{{1
function! s:DiffWithSaved()
    let filetype=&ft
    diffthis
    vnew | r # | normal! 1Gdd
    diffthis
    exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()
