" Include user's local vim config
if filereadable(expand("~/.gvimrc.before"))
  source ~/.gvimrc.before
endif

""
"" Mouse control
"" See: http://vimdoc.sourceforge.net/htmldoc/gui.html#gui-mouse
""

" Despite its name, make the mouse work like any 'window' application;
" right click displays a pop menu, selecting text with the mouse and writing
" will overwrite the text (entering SELECT mode instead VISUAL mode) and
" other thingies
"set behave=mswin

" The following script would map a few keys to a more 'classic' editor;
" ctrl + c and ctrl +v copy/paste for example.
" Note that the following is *not* compatible because it maps keys that are
" used for other stuff
" If you don't mind, uncomment the following:
"source $VIMRUNTIME/mswin.vim

" The behave function (see above) is just a 'bundle' of options that can be
" configured separated.

" Shift-key + arrow text selection
set keymodel=startsel,stopsel

" It just feels more comfortable to have the cursor at the end of the
" selection
set selection=exclusive

" Right click pop-menu
"set mousemodel=popup

" Use SELECT mode when...
" Possible answers (separated comma of words) are mouse, key and cmd
"set selectmode=mouse,key

" Some mappings to cut, copy and paste
" <Ctrl> <Shift> <x>/<c>/<v>
vmap <C-S-x> "+
vmap <C-S-c> "+y
nmap <C-S-v> "+gP

""
"" Most stuff extracted from:
"" http://github.com/carlhuda/janus/blob/master/gvimrc
""

set guifont=Inconsolata-g\ 10           " Default font. Download here: http://www.fantascienza.net/leonardo/ar/inconsolatag/inconsolata-g_font.zip
set guioptions-=T                       " No toolbar
set guioptions-=r                       " No right scrollbar
set guioptions-=L                       " No left scrollbar when v.split
set guioptions+=Aa                      " Highlighted text can be copy/pasted from/to vim
set linespace=3                         " Prefer a slightly higher line height

set background=light
colorscheme solarized
"colorscheme molokai
"colorscheme desert
"colorscheme railscasts

if has("gui_macvim")
  " Fullscreen takes up entire screen
  set fuoptions=maxhorz,maxvert

  " Command-T for CommandT
  macmenu &File.New\ Tab key=<D-T>
  map <D-t> :CommandT<CR>
  imap <D-t> <Esc>:CommandT<CR>

  " Command-Return for fullscreen
  macmenu Window.Toggle\ Full\ Screen\ Mode key=<D-CR>

  " Command-Shift-F for Ack
  map <D-F> :Ack<space>

  " Command-e for ConqueTerm
  map <D-e> :call StartTerm()<CR>

  " Command-/ to toggle comments
  map <D-/> <plug>NERDCommenterToggle<CR>
  imap <D-/> <Esc><plug>NERDCommenterToggle<CR>i


  " Command-][ to increase/decrease indentation
  vmap <D-]> >gv
  vmap <D-[> <gv

  " Map Command-# to switch tabs
  map  <D-0> 0gt
  imap <D-0> <Esc>0gt
  map  <D-1> 1gt
  imap <D-1> <Esc>1gt
  map  <D-2> 2gt
  imap <D-2> <Esc>2gt
  map  <D-3> 3gt
  imap <D-3> <Esc>3gt
  map  <D-4> 4gt
  imap <D-4> <Esc>4gt
  map  <D-5> 5gt
  imap <D-5> <Esc>5gt
  map  <D-6> 6gt
  imap <D-6> <Esc>6gt
  map  <D-7> 7gt
  imap <D-7> <Esc>7gt
  map  <D-8> 8gt
  imap <D-8> <Esc>8gt
  map  <D-9> 9gt
  imap <D-9> <Esc>9gt

  " Command-Option-ArrowKey to switch viewports
  map <D-M-Up> <C-w>k
  imap <D-M-Up> <Esc> <C-w>k
  map <D-M-Down> <C-w>j
  imap <D-M-Down> <Esc> <C-w>j
  map <D-M-Right> <C-w>l
  imap <D-M-Right> <Esc> <C-w>l
  map <D-M-Left> <C-w>h
  imap <D-M-Left> <C-w>h

  " Adjust viewports to the same size
  map <Leader>= <C-w>=
  imap <Leader>= <Esc> <C-w>=
endif

" ConqueTerm wrapper
function! StartTerm()
  execute 'ConqueTerm ' . $SHELL . ' --login'
  setlocal listchars=tab:\ \ 
endfunction

" Project Tree
autocmd VimEnter * call s:CdIfDirectory(expand("<amatch>"))
autocmd FocusGained * call s:UpdateNERDTree()
autocmd WinEnter * call s:CloseIfOnlyNerdTreeLeft()

" Close all open buffers on entering a window if the only
" buffer that's left is the NERDTree buffer
function! s:CloseIfOnlyNerdTreeLeft()
  if exists("t:NERDTreeBufName")
    if bufwinnr(t:NERDTreeBufName) != -1
      if winnr("$") == 1
        q
      endif
    endif
  endif
endfunction

" If the parameter is a directory, cd into it
function! s:CdIfDirectory(directory)
  let explicitDirectory = isdirectory(a:directory)
  let directory = explicitDirectory || empty(a:directory)

  if explicitDirectory
    exe "cd " . fnameescape(a:directory)
  endif

  " Allows reading from stdin
  " ex: git diff | mvim -R -
  if strlen(a:directory) == 0 
    return
  endif

  if directory
    NERDTree
    wincmd p
    bd
  endif

  if explicitDirectory
    wincmd p
  endif
endfunction

" NERDTree utility function
function! s:UpdateNERDTree(...)
  let stay = 0

  if(exists("a:1"))
    let stay = a:1
  end

  if exists("t:NERDTreeBufName")
    let nr = bufwinnr(t:NERDTreeBufName)
    if nr != -1
      exe nr . "wincmd w"
      exe substitute(mapcheck("R"), "<CR>", "", "")
      if !stay
        wincmd p
      end
    endif
  endif

  if exists(":CommandTFlush") == 2
    CommandTFlush
  endif
endfunction

" Utility functions to create file commands
function! s:CommandCabbr(abbreviation, expansion)
  execute 'cabbrev ' . a:abbreviation . ' <c-r>=getcmdpos() == 1 && getcmdtype() == ":" ? "' . a:expansion . '" : "' . a:abbreviation . '"<CR>'
endfunction

function! s:FileCommand(name, ...)
  if exists("a:1")
    let funcname = a:1
  else
    let funcname = a:name
  endif

  execute 'command! -nargs=1 -complete=file ' . a:name . ' :call ' . funcname . '(<f-args>)'
endfunction

function! s:DefineCommand(name, destination)
  call s:FileCommand(a:destination)
  call s:CommandCabbr(a:name, a:destination)
endfunction

" Public NERDTree-aware versions of builtin functions
function! ChangeDirectory(dir, ...)
  execute "cd " . fnameescape(a:dir)
  let stay = exists("a:1") ? a:1 : 1

  NERDTree

  if !stay
    wincmd p
  endif
endfunction

function! Touch(file)
  execute "!touch " . shellescape(a:file, 1)
  call s:UpdateNERDTree()
endfunction

function! Remove(file)
  let current_path = expand("%")
  let removed_path = fnamemodify(a:file, ":p")

  if (current_path == removed_path) && (getbufvar("%", "&modified"))
    echo "You are trying to remove the file you are editing. Please close the buffer first."
  else
    execute "!rm " . shellescape(a:file, 1)
  endif

  call s:UpdateNERDTree()
endfunction

function! Mkdir(file)
  execute "!mkdir " . shellescape(a:file, 1)
  call s:UpdateNERDTree()
endfunction

function! Edit(file)
  if exists("b:NERDTreeRoot")
    wincmd p
  endif

  execute "e " . fnameescape(a:file)

ruby << RUBY
  destination = File.expand_path(VIM.evaluate(%{system("dirname " . shellescape(a:file, 1))}))
  pwd         = File.expand_path(Dir.pwd)
  home        = pwd == File.expand_path("~")

  if home || Regexp.new("^" + Regexp.escape(pwd)) !~ destination
    VIM.command(%{call ChangeDirectory(fnamemodify(a:file, ":h"), 0)})
  end
RUBY
endfunction

" Define the NERDTree-aware aliases
call s:DefineCommand("cd", "ChangeDirectory")
call s:DefineCommand("touch", "Touch")
call s:DefineCommand("rm", "Remove")
call s:DefineCommand("e", "Edit")
call s:DefineCommand("mkdir", "Mkdir")

" Include user's local vim config
if filereadable(expand("~/.gvimrc.after"))
  source ~/.gvimrc.after
endif
