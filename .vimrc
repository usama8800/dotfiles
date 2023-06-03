"
"    #|            #| #| #|     #|  #|#|#|   #|#|#|      "
"     #|          #|  #| #|#|  ##|  #|   #| #|           "
"      #|        #|   #| #| #|# #|  #|  #| #|            "
"       #|      #|    #| #|  #| #|  #|#|   #|            "
"        #|    #|     #| #|     #|  #| #|  #|            "
"         #|  #|      #| #|     #|  #|  #|  #|           "
"          #|#|       #| #|     #|  #|   #|  #|#|#|      "
"
"SETUP STUFF {{{
set nocompatible
set hidden                     " makes unsaved buffers hideable
let mapleader=' '              " set leader to <space>
let maplocalleader='\'
set encoding=utf-8
set backspace=indent,eol,start " be able to backspace everything
set shellslash
syntax enable
filetype plugin indent on
if has('win32')
	let g:vimfolder = '~/vimfiles'
else
	let g:vimfolder = '~/.vim'
endif
" set nrformats-=octal           " don't use <C-a> and <C-x> to increment octals
" set nrformats+=alpha           " use <C-a> and <C-x> to increment letters
set winaltkeys=no              " Alt doesn't go to menu bar
set autoread                   " Auto read file if changed outside
set clipboard+=unnamed         " Use sytem clipboard for yanking and pasting
set tabpagemax=50              " Raise tabs limit
set undolevels=1000
set undofile                   " Save undo history when exiting
let &undodir=g:vimfolder.'/undo'
set history=1000               " Command-line history
set shortmess=a
set gdefault                   " make :s use /g by default
set textwidth=999              " no hard wraps
set formatoptions=tcjo         " Remove comment mark when joining lines
set ignorecase
set path+=**                   " Add all subdirectories for use with :find
set wildmenu                   " Show menu on tab
set wildmode=list,full         " Show list on first tab and fill on second
set wildignore+=*/obj/*
set wildignore+=*/.git/*
set wildignore+=*/bin/*
set wildignore+=*.spec.*
set wildignore+=desktop.ini
set fileformat=unix
set fileformats=unix,dos

" Reset autocmd group
" Will be used to add all autocmds throughout
augroup vimrc
	autocmd!
augroup END
" }}}


" PLUGINS {{{
if has('win32')
	if empty(glob("$HOME/vimfiles/autoload/plug.vim"))
		silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
					\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
		autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
	endif
else
	if empty(glob("$HOME/.vim/autoload/plug.vim"))
		silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
					\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
		autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
	endif
endif
call plug#begin(g:vimfolder.'/plugged')
Plug 'vim-airline/vim-airline'        " Nice status line
Plug 'vim-airline/vim-airline-themes'
Plug 'chrisbra/Colorizer'             " Makes hex colors background the color
Plug 'KabbAmine/vCoolor.vim'          " Color chooser (consider changing)
Plug 'tpope/vim-commentary'           " Comment anything
Plug 'sheerun/vim-polyglot'           " Many more filetypes support
Plug 'mhartington/oceanic-next'       " Theme
Plug 'noahfrederick/vim-hemisu'       " Terminal Theme
Plug 'tpope/vim-surround'             " Surroind text in stuff
" Plug 'SirVer/ultisnips'
" Plug 'adelarsq/vim-matchit'           " Use % to go to matching xml tag
" Plug 'ludovicchabant/vim-gutentags'
Plug 'mbbill/undotree'                " F5 for undo tree
" Plug 'Valloric/MatchTagAlways'        " Highlight xml matching tag
" Plug 'honza/vim-snippets'
Plug 'godlygeek/tabular'              " Nicely tabularize stuff
Plug 'jiangmiao/auto-pairs'           " Braces and quotes pairing
Plug 'farfanoide/vim-kivy'            " Kivy filetype support
call plug#end()
" }}}


" WINDOWS AND BROWSING {{{
let g:netrw_banner=0                       " No netrw banner
let g:netrw_liststyle=0                    " Thin list style
let g:netrw_list_hide='.*\.swp$,^\.\/$'    " Hide swap files
" Functions {{{
function! CustomVimEnter()
	if getcwd() ==? 'C:\Windows\system32' || (expand('%') == '' && getcwd().'/' ==? fnamemodify("~", ":p"))
		cd ~
		execute 'view '.g:vimfolder.'/bookmarks.txt'
		nmap <buffer> l 0v$gfc
	elseif expand('%') ==? ''
		e .
	endif
endfunction
function! AddDirectory(path)
	execute 'tabnew '.g:vimfolder.'/bookmarks.txt'
	execute "normal! Go" . a:path
	w!
	tabclose
endfunction
function! RegexEscape(string)
	return substitute(a:string, "\\\\", "\\\\\\\\", 'g')
endfunction
function! RemoveBookmark(path)
	execute 'tabnew '.g:vimfolder.'/bookmarks.txt'
	execute "/\\v" . a:path
	normal! dd
	w!
	tabclose
endfunction
function! SwapFunction(swapname)
	echom a:swapname
	echom fnamemodify("~/vimfiles/.bookmarks.txt.swp", ":p")
	if a:swapname ==? fnamemodify("~/vimfiles/.bookmarks.txt.swp", ":p")
		return 'e'
	else
		return ''
	endif
endfunction
function! NewSession()
	try
		%bwipeout
	catch
		echom 'Cannot wipeout, unsaved changes'
		return
	endtry
	if has('win32')
		!start gvim ~/vimfiles/bookmarks.txt
	else
		!vim ~/.vim/bookmarks.txt
	endif
	quitall
endfunction
" }}}
" Saving and loading sessions {{{
set sessionoptions-=options      " Don't save global options in sessions
set sessionoptions+=localoptions " Save local options in sessions
" <leader>s# to save session
" <leader>l# to load session
" <leader>ln for new session
" <leader>ll for last session
nnoremap <leader>s1 :execute 'mksession! '.g:vimfolder.'/Sessions/Session1.vim'<cr>
nnoremap <leader>s2 :execute 'mksession! '.g:vimfolder.'/Sessions/Session2.vim'<cr>
nnoremap <leader>s3 :execute 'mksession! '.g:vimfolder.'/Sessions/Session3.vim'<cr>
nnoremap <leader>s4 :execute 'mksession! '.g:vimfolder.'/Sessions/Session4.vim'<cr>
nnoremap <leader>s5 :execute 'mksession! '.g:vimfolder.'/Sessions/Session5.vim'<cr>
nnoremap <leader>s6 :execute 'mksession! '.g:vimfolder.'/Sessions/Session6.vim'<cr>
nnoremap <leader>s7 :execute 'mksession! '.g:vimfolder.'/Sessions/Session7.vim'<cr>
nnoremap <leader>s8 :execute 'mksession! '.g:vimfolder.'/Sessions/Session8.vim'<cr>
nnoremap <leader>s9 :execute 'mksession! '.g:vimfolder.'/Sessions/Session9.vim'<cr>
nnoremap <leader>s0 :execute 'mksession! '.g:vimfolder.'/Sessions/Session0.vim'<cr>
nnoremap <leader>l1 :execute 'source '.g:vimfolder.'/Sessions/Session1.vim'<cr>
nnoremap <leader>l2 :execute 'source '.g:vimfolder.'/Sessions/Session2.vim'<cr>
nnoremap <leader>l3 :execute 'source '.g:vimfolder.'/Sessions/Session3.vim'<cr>
nnoremap <leader>l4 :execute 'source '.g:vimfolder.'/Sessions/Session4.vim'<cr>
nnoremap <leader>l5 :execute 'source '.g:vimfolder.'/Sessions/Session5.vim'<cr>
nnoremap <leader>l6 :execute 'source '.g:vimfolder.'/Sessions/Session6.vim'<cr>
nnoremap <leader>l7 :execute 'source '.g:vimfolder.'/Sessions/Session7.vim'<cr>
nnoremap <leader>l8 :execute 'source '.g:vimfolder.'/Sessions/Session8.vim'<cr>
nnoremap <leader>l9 :execute 'source '.g:vimfolder.'/Sessions/Session9.vim'<cr>
nnoremap <leader>l0 :execute 'source '.g:vimfolder.'/Sessions/Session0.vim'<cr>
nnoremap <leader>ll :execute 'source '.g:vimfolder.'/Sessions/LastSession.vim'<cr>
nnoremap <leader>ln :call NewSession()<cr>
" Autosave session on leaving
autocmd vimrc VimLeave * execute 'mksession! '.g:vimfolder.'/Sessions/LastSession.vim'
" }}}
" Bookmarks {{{
" Open bookmarks when starting without file or directory
autocmd vimrc VimEnter * call CustomVimEnter()
nnoremap <leader>bcd :call AddDirectory(expand('%:p:h'))<cr>
nnoremap <leader>dcd :call RemoveBookmark(expand('%:p:h'))<cr>
" Go to file on line if in bookmarks file
nnoremap <leader>lb :e ~/vimfiles/bookmarks.txt<cr>
autocmd vimrc BufRead ~/vimfiles/bookmarks.txt nmap <buffer> l 0v$gfc
" Open read only for bookmarks file
autocmd vimrc SwapExists * let v:swapchoice = SwapFunction(v:swapname)
" }}}
" Open netrw on new splits
nnoremap <C-w><C-v> :vsplit .<cr>
nnoremap <C-w><C-s> :split .<cr>
set splitbelow " Open splits under
set splitright " Open splits to the right
" :cd to current file's directory
nnoremap <leader>cd :cd %:p:h<cr>
" Window resizing {{{
" Full height
nnoremap <C-w>- <C-w><bar>
" Full width
nnoremap <C-w><C-\> <C-w>_
" Maximize
nnoremap <C-w><C-m> <C-w>_<C-w><bar>
" }}}
nnoremap <C-Tab> :tabnext<cr>
inoremap <C-Tab> <esc>:tabnext<cr>
nnoremap <C-S-Tab> :tabprevious<cr>
inoremap <C-S-Tab> <esc>:tabprevious<cr>
nnoremap <C-t> :tabnew .<cr>
" nnoremap <C-w> :set timeoutlen=1<cr>:q<cr>:set timeoutlen=1000<cr>
nnoremap <leader><C-w> <C-w>
" Open netrw
nnoremap <leader>ee :e .<cr>
" List buffers and get ready to enter a buffer number
nnoremap <leader>bb :buffers<cr>:b<space>
nnoremap <leader>bd :bdelete<cr>
nnoremap <Tab> :bnext<cr>
nnoremap <S-Tab> :bprev<cr>
" Change window with CTRL-[H,J,K,L]
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
" Easier to edit and source vimrc
nnoremap <leader>ev :e $MYVIMRC<cr>
nnoremap <leader>sev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>:simalt ~x<cr>
nnoremap <leader>ss :w<cr>:source %<cr>
" Save on <C-s>
nnoremap <C-s> :w<cr>
inoremap <c-s> <esc>:w<cr>
" }}}


" APPEARENCE {{{
set number            " line numbers
set numberwidth=2     " line number width
set relativenumber
set cursorline        " highlight current line
set lazyredraw        " don't redraw while performing macros and commands
set showmatch         " highlight matching brace
set matchtime=2       " highlight for 2 10th of a second
set hlsearch          " highlight search matches
set incsearch         " show line where match is found
" set synmaxcol=300     " don't check for syntax item after column 300
set display+=lastline " @@@ at the end of last line if too long
set sidescrolloff=5
if !(!has('gui_running') && has('win32'))
	colorscheme OceanicNext
endif
set guifont=Hack:h10,PowerlineSymbols
set guioptions-=T
set guioptions-=l
set guioptions-=L
set guioptions-=r
set guioptions-=R
set guioptions-=m
set guioptions-=M
set background=dark
autocmd vimrc VimResized * execute "normal \<C-w>="
autocmd vimrc GUIEnter * simalt ~x " Set fullscreen window
let g:colorizer_auto_filetype='css'
autocmd vimrc BufNewFile,BufRead *.css,*.html,*.htm :ColorHighlight! " Auto ColorHighlight css and html files
" Resize all windows to same size
set showtabline=2 " Always show tabline
let g:airline#extensions#tabline#enabled = 1               " Let airline take over tabline
let g:airline#extensions#tabline#formatter = 'unique_tail' " tabline names only contain filenames
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline_powerline_fonts = 1                          " Use nice powerline symbols for airline
let g:airline_detect_modified=1
let g:airline_detect_paste=1
" set foldnestmax=4 " Don't go too deep in folding
set foldlevelstart=999 " Open all folds by default
" Set fold method base on filetypes
function! FoldFunction()
	if index(['vim'], &filetype) > -1 " marker foldtype list
		setlocal foldmethod=marker
		setlocal foldlevel=-1
	elseif index([], &filetype) > -1
	else
		setlocal foldmethod=indent
	endif
endfunction
autocmd vimrc BufRead * call FoldFunction()
" Relative numbering and fold column on window focus and regular numbering and no fold column on window blur
autocmd vimrc BufEnter,FocusGained,InsertLeave * set relativenumber foldcolumn=1
autocmd vimrc BufLeave,FocusLost,InsertEnter * set norelativenumber foldcolumn=0
" }}}


" FIX WHITESPACE {{{
set virtualedit=block
set smarttab
set tabstop=4    " show existing tab with 4 spaces width
set shiftwidth=4 " when indenting with '>', use 4 spaces width
set shiftround
set noexpandtab
set autoindent
autocmd FileType python setlocal expandtab
autocmd FileType c setlocal expandtab
autocmd FileType tex setlocal expandtab
set listchars=tab:»\ ,trail:-,nbsp:+,extends:>,precedes:< ",eol:¬ " Show these whitespace characters
let &showbreak='↳' " wrapped line character
set list           " Use listchars
set linebreak      " Don't wrap in the middle of a word
set cpoptions+=n   " use number line for wrapped text
function! TrimWhitespace()
	let l:save = winsaveview()
	keeppatterns %s/\s\+$//e
	call winrestview(l:save)
endfun
nnoremap <leader>f :normal! mqgg=G`q<cr>
nnoremap <leader>t :call TrimWhitespace()<cr>
nnoremap <leader>h i <esc>l
nnoremap <leader>l a <esc>
" }}}


" File-wise mappings {{{

" CSS
" v  = value
" p  = property
" ig = group name
" ag = whole group
autocmd vimrc Filetype css,scss onoremap <buffer> v :<C-u>normal! 0f:lvg_<cr><space>;<esc>i
autocmd vimrc Filetype css,scss onoremap <buffer> p :<C-u>normal! ^vf:h<cr>
autocmd vimrc Filetype css,scss onoremap <buffer> ig :<C-u>execute "normal! j?{\rhv0"<cr>
autocmd vimrc Filetype css,scss onoremap <buffer> ag :<C-u>execute "normal! j?{\r0v/}\r"<cr>

" Netrw
" l = Enter directory or edit file
" b = Bookmark Directory
" h = Move up directory
autocmd vimrc Filetype netrw nmap <buffer> l <cr>
autocmd vimrc Filetype netrw nnoremap <buffer> b :execute 'e '.g:vimfolder.'/bookmarks.txt'<cr>
autocmd vimrc Filetype netrw nmap <buffer> h -

" Tex
autocmd vimrc Filetype tex nnoremap <buffer> <localleader>t a{\Huge Todo}<esc>
autocmd vimrc Filetype tex nnoremap <buffer> <localleader>i a\noindent<esc>
autocmd vimrc Filetype tex nnoremap <buffer> <localleader>s a\textbf{Solution.}<esc>
autocmd vimrc Filetype tex nnoremap <buffer> <localleader>r a\textbf{Proof.}<esc>
autocmd vimrc Filetype tex vmap <buffer> <localleader>b S}i\textbfjk
autocmd vimrc Filetype tex vmap <buffer> <localleader>e S}i\textemjk
autocmd vimrc Filetype tex vmap <buffer> <localleader>e S}i\textemjk
autocmd vimrc Filetype tex inoremap <buffer> <localleader>. \cdot

" Terminal maps
if has('win32')
	tnoremap jk <C-w>N
	tnoremap :q <C-w>c
endif
" <C-z> to run filetypes
nnoremap <C-z> :w
if has('win32')
	autocmd vimrc Filetype python nnoremap <buffer> <localleader>p :w<cr>:!start cmd /k python % && exit<cr>
	autocmd vimrc Filetype python nnoremap <buffer> <localleader>l :w<cr>:!start cmd /k python -i %<cr>
	autocmd vimrc Filetype typescript nnoremap <buffer> <localleader>p :w<cr>:execute "!start cmd /k cd " . getcwd() . " & ng serve -o & pause"<cr>
	autocmd vimrc Filetype tex nnoremap <buffer> <localleader>p :w<cr>:execute printf('!start cmd /c pdflatex --shell-escape "%s" && chrome.exe "%s.pdf"', expand('%'), expand('%:p:r'))<cr>
	autocmd vimrc Filetype tex nnoremap <buffer> <localleader>l :w<cr>:execute printf('!start cmd /c pdflatex --shell-escape "%s" && chrome.exe "%s.pdf" && pause', expand('%:p'), expand('%:p:r'))<cr>
	autocmd vimrc Filetype markdown nnoremap <buffer> <silent> <localleader>p :w<cr>:execute "!start ".expand('%')<cr>
	command! -nargs=* GCC execute printf('!start cmd /c gcc %s.c %s -o %s.exe', expand('%:r'), "<args>", expand('%:r'))
	autocmd vimrc Filetype haskell nnoremap <buffer> <localleader>p :w<cr>:!ghc %<cr>
	autocmd vimrc Filetype haskell nnoremap <buffer> <localleader>l :w<cr>:!ghci %<cr>
	autocmd vimrc Filetype haskell nnoremap <buffer> <localleader>m :w<cr>:!cabal new-repl<cr>
	autocmd vimrc Filetype c nnoremap <buffer> <localleader>p :w<cr>:execute printf('!start cmd /c gcc %s.c -o %s.exe && %s.exe && echo. & echo. && pause',expand('%:r'), expand('%:r'),  expand('%:r'))<cr>
	autocmd vimrc Filetype c nnoremap <buffer> <localleader>l :w<cr>:execute printf('!start cmd /c gdb32 %s.exe', expand('%:r'))<cr>
else
	autocmd vimrc Filetype python nnoremap <buffer> <localleader>p :w<cr>:!python3 %<cr>
	autocmd vimrc Filetype tex nnoremap <buffer> <localleader>p :w<cr>:execute printf('!pdflatex --shell-escape %s; chrome.exe "%s.pdf"', expand('%'), expand('%:p:r'))<cr>
	command! -nargs=* GCC execute printf('!gcc %s -o %s %s', "<args>", expand('%:r'), expand('%'))
	autocmd vimrc Filetype c nnoremap <buffer> <localleader>p :w<cr>:execute printf('!gcc -o %s %s; ./%s', expand('%:r'), expand('%'), expand('%:r'))<cr>
	autocmd vimrc Filetype c nnoremap <buffer> <localleader>d :w<cr>:execute printf('!gdb %s', expand('%:r'))<cr>
	autocmd vimrc Filetype c nnoremap <buffer> <localleader>m :w<cr>:execute '!make && ./driver'<cr>
endif
" }}}


" AUTOCOMPLETES {{{
iabbrev @! usama8800@gmail.com
iabbrev @@ usama@bu.edu
inoremap <c-space> <c-p>
" expand f to find so we can do :f <filename>
cabbrev f find
" snippets
nnoremap ,html :execute 'read '.g:vimfolder.'/snippets/base.html'<CR>ggddG4kA
nnoremap ,c :execute 'read '.g:vimfolder.'/snippets/base.c'<CR>ggdd/main<CR>j

nnoremap <F5> :UndotreeToggle<cr>
let g:undotree_SetFocusWhenToggle = 1
" }}}


" Use it the Vim way {{{
inoremap jk <esc>
inoremap kj <esc>
cnoremap kj <esc>
cnoremap jk <esc>
inoremap <esc> <nop>
noremap <Left> <nop>
inoremap <Left> <nop>
noremap <Right> <nop>
inoremap <Right> <nop>
noremap <Up> <nop>
inoremap <Up> <nop>
noremap <Down> <nop>
inoremap <Down> <nop>
set mouse=""
" }}}


" MISC {{{
nnoremap / /\v
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
vnoremap k gk
vnoremap j gj
vnoremap gk k
vnoremap gj j
nnoremap <leader>; :<up>
vnoremap <leader>; :<up>
nnoremap x "_x
nnoremap <leader>x x
nnoremap cc ciw
nnoremap // :let @/=""<cr>:echo "Search cleared"<cr>
nnoremap <leader>/ :Commentary<cr>j
vnoremap <leader>/ :Commentary<cr>
nnoremap <leader>D ggdG
" Open cmd in current folder
nnoremap <C-c> :execute "!start cmd /K cd " . expand("%:p:h")<cr>
" substitute current selection in file
vnoremap s "sy:%s/<C-r>h//c<left><left>
" new line without going in insert mode
nnoremap <leader>o o<Esc>k
nnoremap <leader>O O<Esc>j
" Go up and down through commands using CTRL+[jk]
cnoremap <C-j> <down>
cnoremap <C-k> <up>
cnoremap <C-h> <left>
cnoremap <C-l> <right>
" Keep curson in center, zz to change
let &scrolloff=999
nnoremap zz :let &scrolloff=999-&scrolloff<cr>
" }}}


" Finding {{{
nnoremap <leader>g :set operatorfunc=GrepOperator<cr>g@
vnoremap <leader>g :<c-u>call GrepOperator(visualmode())<cr>

function! GrepOperator(type)
	let saved_unnamed_register = @@

	if a:type ==# 'v'
		normal! `<v`>y
	elseif a:type ==# 'char'
		normal! `[y`]
	else
		return
	endif

	silent execute "grep! -R " . shellescape(@@) . " ."
	copen

	let @@ = saved_unnamed_register
endfunction
" }}}
