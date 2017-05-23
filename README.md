# vim-jsrf
[![Build Status](https://travis-ci.org/oesse/vim-jsrf.svg?branch=master)](https://travis-ci.org/oesse/vim-jsrf)

Refactorings for javascript in vim.

### Installation

Requirements:
* Vim 8 or NeoVim v0.2.0
* Node 6

###### with [vim-plug](https://github.com/junegunn/vim-plug)
```vim
Plug 'oesse/vim-jsrf', { 'do': 'npm install' }
```
###### with [pathogen](https://github.com/tpope/vim-pathogen)
```sh
cd ~/.vim/bundle
git clone git://github.com/oesse/vim-jsrf.git
cd vim-jsrf && npm install
```

### Usage

In a javascript file use `<leader>rv` to extract the expression under the cursor into a variable. In visual mode a range can be selected to be extracted.

Example:
```javascript
// before:
veryImportantWork(some, expression + args)
//                         cursor  ^
// after :
const foo = expression + args
veryImportantWork(some, foo)
```

