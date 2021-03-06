set nocompatible                      " Forget about vi compatibility... who cares?
let g:pavlim_path = fnamemodify(resolve(expand("<sfile>:p")), ":h")

exe 'source ' .  g:pavlim_path . '/bundle/core/pavlim/plugin/pavlim.vim'

""
"" Customizations
""

" Include user's local vim config
if filereadable(expand("~/.vimrc.before"))
  source ~/.vimrc.before
endif

""
"" Pathogen setup
""

call pavlim#add_bundle('langs')
call pavlim#add_bundle('tools')
call pavlim#add_bundle('libs')
call pavlim#add_bundle('colors')
call pavlim#add_bundle('core')

""
"" Basic configuration
""

set encoding=utf-8
set backup                            " Enable backup
set modeline
set modelines=10                      " Use modeline overrides
set report=0                          " : commands always print changed line count
set viminfo='20,\"50                  " Use a viminfo file,...
set history=100                       " Limit history
set novisualbell                      " Don't blink on errors...
set noerrorbells                      " ...and don't sound either
set ruler                             " Show the cursor position
set title                             " Show title
set t_Co=256                          " Uses 256 colors
set laststatus=2                      " Always show status bar
set showcmd                           " Show command in bottom right portion of the screen
set showmatch                         " Show matching brackets
set matchpairs+=<:>                   " Show matching <> (html mainly) as well
set splitright                        " Makes more sense to open windows on the right than on the left
set colorcolumn=+3                    " Displays a vertical column added/substraced from textwidth (>= Vim 7.3)
set number                            " Show line numbers OR,...
"set relativenumber                    " Relative line numbers (>= Vim 7.3)
"set autowrite                         " Write the old file out when switching between files
"set mouse=a
"set mousehide                         " Hide mouse when typing
set hidden                            " Switch between buffers without saving

filetype plugin indent on             " Enable filetype use
syntax enable                         " Turn on syntax highlighting allowing local overrides

" Session settings
set sessionoptions=buffers,curdir,folds,resize,tabpages,winpos,winsize

" Source the (g)vimrc(.before|.after|.mvim) file after saving it on all instances.
" This way, you don't have to reload Vim to see the changes.
function! UpdateVimRC()
  for server in split(serverlist())
    call remote_send(server, '<Esc>:source $MYVIMRC<CR>
                            \ <Esc>:source $MYGVIMRC<CR>
                            \ <Esc>:source ~/.vim/vimrc.mvim<CR>')
    if filereadable(expand("~/.vimrc.before"))
      call remote_send(server, '<Esc>:source ~/.vim/vimrc.before<CR>')
    endif
    if filereadable(expand("~/.vimrc.after"))
      call remote_send(server, '<Esc>:source ~/.vim/vimrc.after<CR>')
    endif
  endfor
endfunction
autocmd! BufWritePost *vimrc* call UpdateVimRC()

" No blinking cursor. See http://www.linuxpowertop.org/known.php
let &guicursor = &guicursor . ",a:blinkon0"

" Saves file when Vim window loses focus
"autocmd FocusLost * :wa

" Ever notice a slight lag after typing the Leader key + command? This lowers
" the timeout.
set timeoutlen=300

" Statusline setup
" A great article about it:
" http://got-ravings.blogspot.com/2008/08/vim-pr0n-making-statuslines-that-own.html
set statusline=                                   " Clear the statusline for when vimrc is reloaded
set statusline+=[%n]\                             " Buffer number
set statusline+=%f\                               " File name
set statusline+=%h%m%r%w                          " Flags (help,modified,readaonly,preview)
set statusline+=\ [%{strlen(&ft)?&ft:'none'}]     " Filetype
"set statusline+=%{strlen(&fenc)?&fenc:&enc},     " Encoding
"set statusline+=%{&fileformat}]                  " File format
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
set statusline+=%=                                " Right align
set statusline+=%{StatuslineCurrentHighlight()}\  " Highlight
set statusline+=%-14.(%l/%L,%c%V%)\               " Offset (line,total lines,column)
set statusline+=%{fugitive#statusline()}\         " Fugitive (Git)
set statusline+=%<%P                              " Percentage

""
"" Helpers
""

" View changes after the last save
function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
command! DiffSaved call s:DiffWithSaved()

" Some file types should wrap their text
function! s:SetupWrapping()
  set wrap
  set linebreak
  set textwidth=72
  set nolist
endfunction

" Alphabetically sort CSS properties in file with :SortCSS
function! s:SortCSS()
  :g#\({\n\)\@<=#.,/}/sort
endfunction
command! SortCSS call s:SortCSS()

" Remember last location in file
if has("autocmd")
    autocmd BufReadPost *
    \ if line("'\"") > 0 && line ("'\"") <= line("$") |
    \ exe "normal! g'\"" |
    \ endif
endif

" Removes trailing spaces
function! s:RemoveTrailingSpaces()
  %s/\s*$//
  ''
endfunction
command! RemoveTrailingSpaces call s:RemoveTrailingSpaces()

" Return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
    let name = synIDattr(synID(line('.'),col('.'),1),'name')
    if name == ''
        return ''
    else
        return name
    endif
endfunction

" Highlight space errors
let c_space_errors = 1
let python_space_error_highlight = 1
let ruby_space_errors = 1

" Switch to working directory of the open file
autocmd BufEnter * if expand('%:p') !~ '://' | cd %:p:h | endif

"
" Tags
"
set tags=./tags;/home                             " Tags can be in ./tags, ../tags, ..., /home/tags.
set showfulltag                                   " Show more information while completing tags.
set cscopetag                                     " When using :tag, <C-]>, or'vim -t', try cscope:
set cscopetagorder=0                              " try ":cscope find g foo" and then ":tselect foo"

""
"" Mappings
""

" Set the Leader key
let mapleader = ","

" Saves time; maps the spacebar to colon
nmap <Space> :

" Map escape key to jj -- much faster
imap jj <Esc>

" Common mistake
command! W :w

" Map F1 key to Esc.
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

" F2 toggles indenting when pasting
set pastetoggle=<F2>

" Paste from clipboard
map <Leader>p "+gP
map <MouseMiddle> <Esc>"*p

" Set the keys to turn spell checking on/off
map <F8> <Esc>:setlocal spell spelllang=en_us<CR>
map <F9> <Esc>:setlocal nospell<CR>

" Map w!! to write file with sudo, when forgot to open with sudo
cmap w!! w !sudo tee % >/dev/null

" Check changes from the last save
nnoremap <Leader>? :DiffSaved<CR>

" Hard-wrap paragraphs of text
nnoremap <Leader>q gqip

" Easier window navigation
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

" Easier tab navigation
" noremap <silent> <C-Tab> :tabnext<cr>
" noremap <silent> <C-S-Tab> :tabprevious<cr>

" Map the arrow keys to be based on display lines, not physical lines
map <Down> gj
map <Up> gk

" Shortcut for editing  vimrc file in a new tab
nmap <Leader>ev :tabedit $MYVIMRC<CR>

" Bubble single lines (with unimpaired plugin)
" If you want an alternative way to do this without a plugin
" check: http://vimcasts.org/episodes/bubbling-text/
nmap <C-Up> [e
nmap <C-Down> ]e

" Bubble multiple lines (with unimpaired plugin)
vmap <C-Up> [egv
vmap <C-Down> ]egv

" Opens a tab edit command with the path of the currently edited file filled in
" Normal mode: <Leader>te
map <Leader>te :tabe <C-R>=expand("%:p:h") . "/" <CR>

" Opens the directory browser for the directory of the current path.
" Normal mode: <Leader>e
map <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

" Inserts the path of the currently edited file into a command
" Command mode: Ctrl+P
cmap <C-P> <C-R>=expand("%:p:h") . "/" <CR>

" Get to home dir easier
" <Leader>hm is easier to type than :cd ~
nmap <Leader>hm :cd ~/ <CR>

" Opens a vertical split and switches over (\v)
nnoremap <Leader>v <C-w>v<C-w>l

" Delete all buffers (via Derek Wyatt)
nmap <silent> ,da :exec "1," . bufnr('$') . "bd"<CR>

" Saves file
nmap <C-s> :w<CR>

" Shifting lines (aka indentation)
nmap <M-S-Left> <<
nmap <M-S-Right> >>
vmap <M-S-Left> <gv
vmap <M-S-Right> >gv

" Call omnicompletion easily
imap <C-Space> <C-x><C-o>

""
"" Backups
""
set updatetime=2000                   " Write swap files after 2 seconds of inactivity.
set undodir=~/.vim/tmp/undo//         " Undo files
set backupdir=~/.vim/tmp/backup//     " Backups
set directory=~/.vim/tmp/swap//       " Swap files

" Don't write swapfile on most commonly used directories for NFS mounts or USB sticks
autocmd BufNewFile,BufReadPre /media/*,/mnt/* set directory=~/tmp,/var/tmp,/tmp

""
"" Whitespace/tab/indent stuff
""
set nowrap                            " Don't wrap lines
set autoindent
set expandtab                         " Use spaces, not tabs
set smarttab                          " Smart tabulation and backspace
set smartindent                       " Uses smart indent if there's no indent file
set tabstop=2                         " A tab is 2 (two) spaces
set shiftwidth=2                      " An autoindent (with <<) is two spaces
set softtabstop=2                     " Two spaces when editing
set list listchars=trail:⋅,nbsp:⋅,tab:\ \    " Show non-printing characters for tabs and trailing spaces
set backspace=indent,eol,start        " Allow backspacing over everything

" Searching
set hlsearch                          " Highlight search while typing a /regex
set incsearch                         " Incrementally search while typing a /regex
set ignorecase                        " Default to using case insesitive searches...
set smartcase                         " ...unless uppercase are used

" Remove highlighting search results
nnoremap <Leader><Space> :nohlsearch <CR>

""
"" Tab completion and folding
""

" Enable code folding by syntax
set foldmethod=syntax
set nofoldenable                      " But don't start with it

" Fold tags
" Normal mode: <Leader>ft
nnoremap <Leader>ft Vatzf

" Completion
set wildmenu
set wildmode=longest,list
set wildignore+=*.o,*.obj,.git,*.rbc,*.class,.svn,vendor/gems/*
setlocal omnifunc=syntaxcomplete#Complete  " enable syntax based omni completion

""
"" Filetype
""

if has("cscope") && filereadable("/usr/bin/cscope")
   set csprg=/usr/bin/cscope
   set csto=0
   set cst
   set nocsverb
   " add any database in current directory
   if filereadable("cscope.out")
      cs add cscope.out
   " else add database pointed to by environment
   elseif $CSCOPE_DB != ""
      cs add $CSCOPE_DB
   endif
   set csverb
endif

" Markdown, textile and txt files should wrap
autocmd BufRead,BufNewFile *.{md,markdown,mdown,mkd,mkdn,txt,textile} call s:SetupWrapping()

" Make Python (and sh) follow PEP8 ( http://www.python.org/dev/peps/pep-0008/ )
autocmd FileType python,sh setlocal softtabstop=4 tabstop=4 shiftwidth=4 textwidth=79 colorcolumn=79

" make uses real tabs (not spaces)
autocmd FileType make setlocal noexpandtab

" Thorfile, Rakefile, Vagrantfile and Gemfile are Ruby
autocmd BufRead,BufNewFile {Gemfile,Rakefile,Vagrantfile,Thorfile,config.ru} setlocal filetype=ruby

" Add json syntax highlighting
autocmd BufNewFile,BufRead *.json setlocal ft=javascript

" rst
autocmd BufNewFile,BufRead *.rst setlocal ft=rst
autocmd FileType rst setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4 colorcolumn=79
\ formatoptions+=nqt textwidth=74

" CSS
autocmd FileType css setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4

" Javascript
autocmd FileType javascript setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2 colorcolumn=79
let javascript_enable_domhtmlcss=1

" Vala
autocmd BufRead *.vala set efm=%f:%l.%c-%[%^:]%#:\ %t%[%^:]%#:\ %m
autocmd BufRead *.vapi set efm=%f:%l.%c-%[%^:]%#:\ %t%[%^:]%#:\ %m
autocmd BufRead,BufNewFile *.vala  setfiletype vala
autocmd BufRead,BufNewFile *.vapi  setfiletype vala
let vala_comment_strings = 1
let vala_space_errors = 1
let vala_no_tab_space_error = 1

" Vim
autocmd FileType vim setlocal expandtab shiftwidth=2 tabstop=8 softtabstop=2

" Template language support (SGML / XML too)
" ------------------------------------------
" See: https://github.com/mariocesar/dotfiles

autocmd FileType html,xhtml,xml,htmldjango,htmljinja,eruby,mako setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd BufNewFile,BufRead *.rhtml setlocal ft=eruby
autocmd BufNewFile,BufRead *.mako setlocal ft=mako
autocmd BufNewFile,BufRead *.tmpl setlocal ft=htmljinja
autocmd BufNewFile,BufRead *.py_tmpl setlocal ft=python
"autocmd BufNewFile,BufRead *.html,*.htm

" Disable that stupid html rendering (like making stuff bold, underlining, etc)
let html_no_rendering=1

" Set up an HTML5 template for all new .html files
"autocmd BufNewFile * silent! 0r $VIMHOME/templates/%:e.tpl

""
"" Plugins
""

" NerdTREE
nnoremap <Leader>n :NERDTreeToggle<CR>
let NERDTreeIgnore=['\.pyc$', '\.rbc$', '\~$']

" NerdTREE - use colors, cursorline and return/enter key
let NERDChristmasTree = 1
let NERDTreeHighlightCursorline = 1
let NERDTreeMapActivateNode='<CR>'

" MiniBufExplorer - switch with s-tab and c-s-tab
let g:miniBufExplMapCTabSwitchBufs = 1

" CTags
map <Leader>rt :!ctags --extra=+f -R *<CR><CR>
map <C-\> :tnext<CR>

" Scratch - define invoke function
function! ToggleScratch()
  if expand('%') == g:ScratchBufferName
    quit
  else
    Sscratch
  endif
endfunction

" Scratch - keys to toggle Scratch buffer
map <Leader>s :call ToggleScratch()<CR>

" Syntastic - enable syntax checking
let g:syntastic_enable_signs=1
let g:syntastic_quiet_warnings=1

" Gist-vim
if has("mac")
  let g:gist_clip_command = 'pbcopy'
elseif has("unix")
  let g:gist_clip_command = 'xclip -selection clipboard'
endif
let g:gist_detect_filetype = 1
let g:gist_open_browser_after_post = 1

" Matchit - % to bounce from do to end etc.
runtime! macros/matchit.vim

" Ack - uncomment suitable line if configuration is necessary
"let g:ackprg="ack -H --nocolor --nogroup"         " If ack --version < 1.92
"let g:ackprg="ack-grep -H --nocolor --nogroup"    " For Debian/Ubuntu

" Conque - launch terminal
nnoremap <Leader><Leader>t :ConqueTermSplit bash<CR>

" Rails - turn off rails related things in statusbar
"let g:rails_statusline=0

" RVM
set statusline+=%{exists('g:loaded_rvm')?rvm#statusline():''}

" LaTeX - configuration
set grepprg=grep\ -nH\ $*
let g:tex_flavor='latex'

" Turn off jslint errors by default
let g:JSLintHighlightErrorLine = 0

" Zencoding-wim - change expansion leader key to Ctrl + e
" If you just use the expand feature uncomment the following line
" let g:user_zen_expandabbr_key = '<C-e>'
let g:user_zen_leader_key = '<C-e>'
let g:user_zen_settings = {
\ 'html' : {
\ 'indentation' : '  '
\ },
\}

" ZoomWin configuration
map <Leader><Leader>z :ZoomWin<CR>

" Without setting this, ZoomWin restores windows in a way that causes
" equalalways behavior to be triggered the next time CommandT is used.
" This is likely a bludgeon to solve some other issue, but it works
set noequalalways

" Command-T configuration
let g:CommandTMaxHeight=20

" SuperTab
let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabCompletionContexts = ['s:ContextText', 's:ContextDiscover']
let g:SuperTabContextTextOmniPrecedence = ['&omnifunc', '&completefunc']
let g:SuperTabContextDiscoverDiscovery = ["&completefunc:<c-x><c-u>", "&omnifunc:<c-x><c-o>"]

" TComment mappings
imap <C-S-c> <C-_><C-_>

" TComment - NerdCommenter like mappings
map <Leader>cc <C-_><C-_>
map <Leader>c<Space> <C-_><C-_>
map <Leader>cn <C-_>b

" EasyMotion - Change default key
let g:EasyMotion_leader_key='<Leader><Leader>'

" vim-session - session autosave
let g:session_autosave = 1

""
"" Colors and eye-candy
""

"Here's 100 to choose from: http://www.vim.org/scripts/script.php?script_id=625
"colorscheme railscasts_alt
"colorscheme desert
"colorscheme molokai
colorscheme jellybeans

""
"" Miscellaneous stuff
""

" Helpeful abbreviations
iab lorem Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
iab llorem Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

" Spelling corrects. Just for example. Add yours below.
iab teh the
iab Teh The

let macvim_hig_shift_movement = 1     " mvim shift-arrow-keys (required in vimrc)

" Load mac specific stuff
if has("mac")
  source ~/.vimrc.mvim
endif

""
"" Customizations
""
" Include user's local vim config
if filereadable(expand("~/.vimrc.after"))
  source ~/.vimrc.after
endif
