set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

"ADDED Powerline
" Plugin 'powerline/powerline'
Bundle 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
" ADDED Nerdtree
Plugin 'scrooloose/nerdtree'
" ADDED Nerdtree-Tab
Bundle 'jistr/vim-nerdtree-tabs'
" ADDED Syntastic : Syntax checking hacks for vim
Plugin 'scrooloose/syntastic'
" ADDED SuperTab
Plugin 'ervandew/supertab'
" ADDED Ultisnips
Plugin 'SirVer/ultisnips'   
" Snippets are separated from the engine. Add this if you want them:
Plugin 'honza/vim-snippets'
" ADDED Dracula colour scheme.
Plugin 'dracula/vim', { 'name': 'dracula' }
" ADDED YouCompleteMe 
" Plugin 'Valloric/YouCompleteMe'
" ADDED indent python
Plugin 'vim-scripts/indentpython.vim'
" ADDED SimplyFold
Plugin 'tmhedberg/SimplyFold'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
" Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" Non Vundle stuff ************************************************

set nocompatible                " Makes vim incompatibile with vi
set t_Co=256    
set modelines=0  
set autoread                    " Auto reads when file is changed from outside
set encoding=utf-8              " Set UTF 8 standard
command! -nargs=0 Sw w !sudo tee % > /dev/null 


syntax on                       " Syntax highlighting
colors dracula                  " enable dracula color scheme duh
set smarttab                    " Insert tab on start of line base on context
set hlsearch                    " Search highlighting
set incsearch                   " Show search matches as you type
set ignorecase                  " Ignores case when searching
set smartcase                   " Ignore case if search pattern is all 
                                "   lower case, case sensitive otherwise
filetype plugin indent on       " Auto detects filetypes

set nobackup                    " Do not keep backup files
set noswapfile                  " Do not write swap files
set noerrorbells                " Disable beeping
set visualbell
set t_vb=
set tm=500


set nowrap                      " Do not wrap long lines
set autoindent                  " Auto indenting on
set copyindent                  " Copy previous indentation on auto
set foldenable                  " Auto fold code
set showmode                    " Show current mode currently in
set showmatch                   " Cursor shows matching parentthesis
"set number                      " Shows line numbers
set relativenumber              " Show line number relative to cursor


set wildmenu                    " Tab completion for files act like in bash
set wildmode=list:full          " Show list when pressing tab
set spell                       " Spell check enabled

set mouse=a                     " Enable mousesset  

set backspace=indent,eol,start  " Backspace for dummies
set linespace=0                 " No extra spaces between rows
set numberwidth=1               
set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too

set scrolloff=0
set virtualedit=all
set fileformats="unix,dos,mac"
set formatoptions+=1
set ruler

set textwidth=80
set linebreak
set fo+=t
set wrapmargin=0
"set columns=80
set wrap!                       " Prevent wrapping that goes off screen

" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

if has("autocmd")
    au BufReadPost *.rkt,*.rktl set filetype=racket
    au filetype racket set lisp
    au filetype racket set autoindent
endif
               
" Save mouse position
augroup resCur
    autocmd!
    autocmd BufReadPost * call setpos(".", getpos("'\""))
augroup END   


" NerdTree settings
" Automatically opens up nerdtree
"autocmd vimenter * NERDTree     
" Opens nerdtree with Control-n
map <C-n> :NERDTreeToggle<CR>
" Closes nerdtree if vim closes
let g:nerdtree_tabs_autoclose=1

" Syntastic Settins
" recommended?
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

set rtp+="$POWERLINE_PATH/powerline/bindings/vim"

let g:powerline_pycmd="py3"  
let g:Powerline_symbols = 'fancy'

let s:uname = system("uname")
if s:uname == "Darwin\n"
    set guifont=Inconsolata\ for\ Powerline:h15
    set fillchars+=stl:\ ,stlnc:\
endif

python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup

set laststatus=2                   " show powerline all the time
"set showtabline=2      " Always display the tabline
"set noshowmode  " Hide the default mode text

" split navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Enable folding
set foldmethod=indent
set foldlevel=99

set tabstop=4
set shiftwidth=4

set expandtab
