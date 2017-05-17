# vim-jsr
Refactorings for javascript in vim.

### Installation

Tested with Vim 8 and Node 7.

###### with [vim-plug](https://github.com/junegunn/vim-plug)
```vim
Plug 'oesse/vim-jsr', { 'do': 'npm install' }
```
###### with [pathogen](https://github.com/tpope/vim-pathogen)
```sh
cd ~/.vim/bundle
git clone git://github.com/oesse/vim-jsr.git
cd vim-jsr && npm install
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

