" Begin latte.vim
if exists("b:current_syntax")
  finish
endif

" use html syntax
runtime! syntax/html.vim

" Define a list of Latte custom tags
let s:latteCustomTags = [
      \ 'if', 'elseif', 'else', 'ifset', 'elseifset', 'ifchanged', 'switch', 'case', 'default',
      \ 'foreach', 'for', 'while', 'continueIf', 'skipIf', 'breakIf', 'exitIf', 'first', 'last',
      \ 'sep', 'iterateWhile', 'include', 'sandbox', 'block', 'define', 'import',
      \ 'layout', 'embed', 'try', 'rollback', 'var', 'default', 'parameters', 'capture',
      \ 'varType', 'varPrint', 'templateType', 'templatePrint', 'translate',
      \ 'contentType', 'debugbreak', 'do', 'dump', 'php', 'spaceless', 'syntax', 'trace',
      \ 'link', 'plink', 'control', 'snippet', 'snippetArea', 'cache', 'form', 'label',
      \ 'input', 'inputError', 'formContainer'
      \ ]

" Apply syntax highlighting to all Latte keywords
for tag in s:latteCustomTags
    execute 'syntax keyword latteCustomTag' tag
endfor

syntax match latteInterpolation /{\$\w\+}/

highlight link latteCustomTag Keyword
highlight link latteInterpolation Identifier

" Define a syntax region for block comments:
syntax region latteBlockComment start=/{\*/ end=/\*\}/ keepend

" Link the block comment region to the Comment highlight group
highlight link latteBlockComment Comment

autocmd FileType latte setlocal omnifunc=htmlcomplete#Complete

" Set the syntax name to prevent reloading.
let b:current_syntax = "latte"
