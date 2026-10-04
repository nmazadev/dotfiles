" cozy: a vim colorscheme that uses the terminal's 16 ANSI colors only, so it
" follows whichever desktop theme is active (cocoa, nord, ...).
" ANSI: 1 red/accent, 2 green, 3 yellow/amber, 4 blue, 5 magenta, 6 cyan, 8 muted.

highlight clear
if exists("syntax_on") | syntax reset | endif
let g:colors_name = "cozy"
set background=dark

function! s:hi(group, fg, bg, attr) abort
    execute 'highlight ' . a:group . ' ctermfg=' . a:fg . ' ctermbg=' . a:bg . ' cterm=' . a:attr . ' gui=' . a:attr
endfunction

" editor chrome
call s:hi('Normal',       'NONE', 'NONE', 'NONE')
call s:hi('LineNr',       '8',    'NONE', 'NONE')
call s:hi('CursorLineNr', '1',    'NONE', 'bold')
call s:hi('CursorLine',   'NONE', 'NONE', 'NONE')
call s:hi('NonText',      '8',    'NONE', 'NONE')
call s:hi('EndOfBuffer',  '8',    'NONE', 'NONE')
call s:hi('SignColumn',   'NONE', 'NONE', 'NONE')
call s:hi('VertSplit',    '8',    'NONE', 'NONE')
call s:hi('StatusLine',   '7',    '8',    'NONE')
call s:hi('StatusLineNC', '8',    '0',    'NONE')
call s:hi('Visual',       '0',    '3',    'NONE')
call s:hi('Search',       '0',    '3',    'NONE')
call s:hi('IncSearch',    '0',    '1',    'NONE')
call s:hi('MatchParen',   '1',    'NONE', 'bold,underline')
call s:hi('Pmenu',        '7',    '8',    'NONE')
call s:hi('PmenuSel',     '0',    '1',    'NONE')
call s:hi('Folded',       '8',    'NONE', 'italic')
call s:hi('Directory',    '4',    'NONE', 'NONE')
call s:hi('Title',        '1',    'NONE', 'bold')
call s:hi('ErrorMsg',     '0',    '1',    'NONE')
call s:hi('WarningMsg',   '3',    'NONE', 'NONE')
call s:hi('MoreMsg',      '2',    'NONE', 'NONE')
call s:hi('Question',     '2',    'NONE', 'NONE')

" syntax
call s:hi('Comment',      '8',    'NONE', 'italic')
call s:hi('Constant',     '3',    'NONE', 'NONE')
call s:hi('String',       '2',    'NONE', 'NONE')
call s:hi('Number',       '3',    'NONE', 'NONE')
call s:hi('Identifier',   '6',    'NONE', 'NONE')
call s:hi('Function',     '4',    'NONE', 'NONE')
call s:hi('Statement',    '5',    'NONE', 'NONE')
call s:hi('PreProc',      '1',    'NONE', 'NONE')
call s:hi('Type',         '3',    'NONE', 'NONE')
call s:hi('Special',      '6',    'NONE', 'NONE')
call s:hi('Delimiter',    '7',    'NONE', 'NONE')
call s:hi('Underlined',   '4',    'NONE', 'underline')
call s:hi('Todo',         '0',    '3',    'bold')
call s:hi('Error',        '0',    '1',    'NONE')

" diffs
call s:hi('DiffAdd',      '2',    'NONE', 'NONE')
call s:hi('DiffDelete',   '1',    'NONE', 'NONE')
call s:hi('DiffChange',   '3',    'NONE', 'NONE')
call s:hi('DiffText',     '0',    '3',    'NONE')
