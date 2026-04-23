set rtp+=.

" nix shell
if !empty($PLENARY_PATH)
  exe 'set rtp+=' . $PLENARY_PATH
endif

set rtp+=../plenary.nvim

" vim-plug
set rtp+=~/.vim/plugged/plenary.nvim

" packer
set rtp+=~/.local/share/nvim/site/pack/packer/start/plenary.nvim

" lunarvim
set rtp+=~/.local/share/lunarvim/site/pack/packer/start/plenary.nvim

" lazy
set rtp+=~/.local/share/nvim/lazy/plenary.nvim

" vim.pack
set rtp+=~/.local/share/nvim/site/pack/core/opt/plenary.nvim/

runtime! plugin/plenary.vim
