" File: syntax/neon.vim
if exists("b:current_syntax")
  finish
endif

" For now, reuse YAML syntax
runtime! syntax/yaml.vim
let b:current_syntax = "neon"
