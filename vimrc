" --- Essential Settings ---

set nocompatible    " Enable modern Vim features
set nomodeline      " Security: ignore modelines in files
filetype plugin indent on " Load filetype-specific plugins and indent rules
syntax on           " Enable syntax highlighting


" --- Editor Behavior ---

set number           " Show line numbers
set ruler            " Always show cursor position
set showcmd          " Display incomplete commands
set history=1000     " Store a lot of command history
set hidden           " Allow switching buffers without saving
set mouse=a          " Enable mouse use in all modes
set scrolloff=8      " Keep 8 lines of context above/below cursor
set sidescrolloff=8  " Keep 8 columns of context left/right of cursor
set signcolumn=yes   " Always show the sign column (prevents text shift)

set backspace=indent,eol,start " Allow backspace over everything


" --- Search Settings ---

set incsearch       " Find as you type (incremental search)
set hlsearch        " Highlight all search matches
set ignorecase      " Make all searches case-insensitive...
set smartcase       " ...unless the search pattern contains an uppercase letter

" Add a mapping to easily clear search highlighting
nnoremap <leader><space> :nohlsearch<CR>


" --- Indentation Settings ---

set tabstop=4       " Number of spaces a <Tab> counts for
set shiftwidth=4    " Number of spaces for auto-indent
set expandtab       " Use spaces instead of actual tab characters
set softtabstop=4   " Number of spaces <Tab> key inserts/deletes in insert mode
set autoindent      " Copy indent from current line when starting a new line


" --- Command & Completion ---

set wildmenu        " Show a graphical menu for command-line completion
set wildmode=longest:full,full " More advanced completion behavior
set showmatch       " Briefly jump to matching bracket/brace
set completeopt=menu,menuone,noselect " Better settings for autocompletion


" --- File Management (Backups & Undo) ---

" This creates a persistent undo history for all your files.
try
    set backupdir=~/.vim/backup
    if !isdirectory(&backupdir)
        call mkdir(&backupdir, "p", 0700)
    endif

    set directory=~/.vim/swap
    if !isdirectory(&directory)
        call mkdir(&directory, "p", 0700)
    endif
catch
endtry

nnoremap j <Left>
nnoremap h ; 

" Visual mode
vnoremap ; <Right>
vnoremap l <Up>
vnoremap k <Down>
vnoremap j <Left>
vnoremap h ;

" Your window-switching movements, mirrored
nnoremap <C-w>; <C-w>l " Window Right
nnoremap <C-w>l <C-w>k " Window Up
nnoremap <C-w>k <C-w>j " Window Down
nnoremap <C-w>j <C-w>h " Window Left
nnoremap <C-w>h <C-w>; " Swap h and ;

" Your tab navigation (now non-recursive)
nnoremap <C-S-tab> :tabprevious<CR>
nnoremap <C-tab>   :tabnext<CR>
nnoremap <C-t>     :tabnew<CR>

" Also map in Insert mode for convenience
inoremap <C-S-tab> <Esc>:tabprevious<CR>i
inoremap <C-tab>   <Esc>:tabnext<CR>i
inoremap <C-t>     <Esc>:tabnew<CR>i

" --- Style and Appearance ---

if has('termguicolors')
  set termguicolors
endif
