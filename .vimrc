" swap j and k in normal, visual, and operator-pending modes
nnoremap <silent> j k
vnoremap <silent> j k
onoremap <silent> j k

nnoremap <silent> k j
vnoremap <silent> k j
onoremap <silent> k j

" ctrl-k and ctrl-j to move between splits (reversed)
nnoremap <silent> <C-k> <C-w>j
vnoremap <silent> <C-k> <C-w>j
onoremap <silent> <C-k> <C-w>j

nnoremap <silent> <C-j> <C-w>k
vnoremap <silent> <C-j> <C-w>k
onoremap <silent> <C-j> <C-w>k

" disable capital J in normal mode, annoying
nnoremap <silent> J <Nop>
