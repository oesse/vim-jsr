# vim-jsrf
[![Build Status](https://travis-ci.org/oesse/vim-jsrf.svg?branch=master)](https://travis-ci.org/oesse/vim-jsrf)

Refactorings for javascript in vim.

### Installation

Requirements:
* Vim 8 or NeoVim v0.2.0
* Node 5

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

In a javascript file use `<leader>r` as the prefix for refactoring commands in normal and visual mode. Available refactorings:

| default mapping | name | description |
| --- | --- | --- |
| `<leader>rv` | extract variable | Extract the expression under the cursor to new const variable |
| `<leader>re` | expand object    | Put each property of object literal on a line of its own |
| `<leader>rc` | collapse object  | Put the object literal on a single line |

You can change the refactorings prefix in your vimrc:
```vim
let g:jsrf_map_leader = '\'
```
