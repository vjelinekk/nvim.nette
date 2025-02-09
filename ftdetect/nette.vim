" File: ftdetect/nette.vim
augroup NetteFiletypes
  autocmd!
  autocmd BufRead,BufNewFile *.latte set filetype=latte.html
  autocmd FileType latte.html runtime! syntax/latte.vim
  autocmd BufRead,BufNewFile *.neon  set filetype=neon
  autocmd FileType neon execute 'source ' . expand('<sfile>:p:h') . '/../ident/neon.vim'
augroup END
