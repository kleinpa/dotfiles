" FreeBSD security advisory for this one...
set nomodeline

" This setting prevents vim from emulating the original vi's
" bugs and limitations.
set nocompatible

" turn on syntax highlighting
syntax on
" Make it not as appaling on dark background
highlight Comment ctermfg=Cyan term=NONE cterm=NONE

" turn on line numbers, aww yeah
set number

" The first setting tells vim to use "autoindent" (that is, use the current
" line's indent level to set the indent level of new lines). The second makes
" vim attempt to intelligently guess the indent level of any new line based on
" the previous line.
set autoindent
"set smartindent

" I prefer 4-space tabs to 8-space tabs. The first setting sets up 4-space
" tabs, and the second tells vi to use 4 spaces when text is indented (auto or
" with the manual indent adjustmenters.)
set tabstop=4
set shiftwidth=4
set expandtab
set softtabstop=4

" This setting will cause the cursor to very briefly jump to a 
" brace/parenthese/bracket's "match" whenever you type a closing or 
" opening brace/parenthese/bracket.
"set showmatch

" find as you type
"set incsearch

" make searches case-insensitive
set ignorecase
" unless they contain upper-case letters
set smartcase

" have fifty lines of command-line (etc) history:
set history=50

" This setting ensures that each window contains a statusline that displays the
" current cursor position.
set ruler

" Display an incomplete command in the lower right corner of the Vim window
set showcmd

set bs=2

" It feels weird at first but is quite useful.
"set virtualedit=all
" tab navigation like firefox
:nmap <C-S-tab> :tabprevious<CR>
:nmap <C-tab> :tabnext<CR>
:nmap <C-t> :tabnew<CR>
:map <C-S-tab> :tabprevious<CR>
:map <C-tab> :tabnext<CR>
:map <C-t> :tabnew<CR>

if has("gui_running")
    set background=light
    colorscheme solarized
    set guifont=Consolas:h11
endif

" Normal mode
nmap ; <Right>
nmap l <Up>
nmap k <Down>
nmap j <Left>
nnoremap h ;

" Visual mode
vmap ; <Right>
vmap l <Up>
vmap k <Down>
vmap j <Left>
vnoremap h ;

" Rebind the window-switching movements
nnoremap <C-w>; <C-w>l
nnoremap <C-w>l <C-w>k
nnoremap <C-w>k <C-w>j
nnoremap <C-w>j <C-w>h
nnoremap <C-w>h <C-w>;

nnoremap <C-w>j <C-w>h
nnoremap <C-w><C-j> <C-w>h

