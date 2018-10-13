{ config, pkgs, ... }:

{
  system.defaults.dock.autohide = true;
  system.defaults.dock.orientation = "left";
  system.defaults.dock.showhidden = true;
  system.defaults.dock.mru-spaces = false;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs;
    [ nix-repl

      curl
      emacs
      git
      gnupg
      htop
      jq
      nix-prefetch-git
      tree
    ];

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.bash.enable = true;
  programs.zsh.enable = true;

  programs.tmux.enable = true;
  programs.tmux.enableSensible = true;
  programs.tmux.enableMouse = true;
  programs.tmux.enableFzf = true;
  programs.tmux.enableVim = true;

  programs.tmux.tmuxConfig = ''
    set -g status-bg black
    set -g status-fg white
    set -g default-terminal "screen-256color"
    unbind C-b
    set -g prefix C-j
  '';

  programs.vim.enable = true;
  programs.vim.enableSensible = true;

  programs.vim.plugins = [
    { names = [ "ReplaceWithRegister" "vim-indent-object" "vim-sort-motion" ]; }
    { names = [ "ale" "vim-gitgutter" "vim-dispatch" ]; }
    { names = [ "commentary" "vim-eunuch" "repeat" "tabular" ]; }
    { names = [ "fzfWrapper" "fzf-vim" "youcompleteme" ]; }
    { names = [ "gist-vim" "webapi-vim" ]; }
    { names = [ "polyglot" "colors-solarized" ]; }
    { names = [ "python-mode" ]; }
  ];

  programs.vim.vimConfig =  ''
    colorscheme solarized
    set bg=dark
    set clipboard=unnamed
    set relativenumber
    set backup
    set backupdir=~/.vim/tmp/backup//
    set backupskip=/tmp/*,/private/tmp/*
    set directory=~/.vim/tmp/swap/
    set noswapfile
    set undodir=~/.vim/tmp/undo//
    set undofile
    if !isdirectory(expand(&undodir))
      call mkdir(expand(&undodir), "p")
    endif
    if !isdirectory(expand(&backupdir))
      call mkdir(expand(&backupdir), "p")
    endif
    if !isdirectory(expand(&directory))
      call mkdir(expand(&directory), "p")
    endif
    vmap s S
    inoremap <C-g> <Esc><CR>
    vnoremap <C-g> <Esc><CR>
    cnoremap <C-g> <Esc><CR>
    cnoremap %% <C-r>=expand('%:h') . '/'<CR>
    let mapleader = ' '
    nnoremap <Leader>( :tabprevious<CR>
    nnoremap <Leader>) :tabnext<CR>
    nnoremap <Leader>! :Dispatch!<CR>
    nnoremap <Leader>p :FZF<CR>
    nnoremap <silent> <Leader>e :exe 'FZF ' . expand('%:h')<CR>
    nmap <leader><tab> <plug>(fzf-maps-n)
    xmap <leader><tab> <plug>(fzf-maps-x)
    omap <leader><tab> <plug>(fzf-maps-o)
    imap <c-x><c-w> <plug>(fzf-complete-word)
    command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>,
          \   <bang>0 ? fzf#vim#with_preview('up:30%')
          \   : fzf#vim#with_preview('right:50%:hidden', '?'),
          \   <bang>0)
    command! -bang -nargs=* Rg call fzf#vim#grep(
          \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
          \   <bang>0 ? fzf#vim#with_preview('up:30%')
          \           : fzf#vim#with_preview('right:50%:hidden', '?'),
          \   <bang>0)
    highlight clear SignColumn
    let g:is_bash=1
    let g:ale_sign_error = '⨉'
    let g:ale_sign_warning = '⚠'
    let g:ale_virtualenv_dir_names = ['venv']
    " let g:ycm_add_preview_to_completeopt = 1
    let g:ycm_autoclose_preview_window_after_completion = 1
    let g:ycm_autoclose_preview_window_after_insertion = 1
    let g:ycm_seed_identifiers_with_syntax = 1
    let g:ycm_semantic_triggers = {}
    nmap <Leader>D :YcmCompleter GetDoc<CR>
    nmap <Leader>d :YcmCompleter GoToDefinition<CR>
    nmap <Leader>r :YcmCompleter GoToReferences<CR>
    let g:pymode_folding = 0
    let g:pymode_lint = 0
    let g:pymode_options_colorcolumn = 0
    let g:pymode_options_max_line_length = 120
    let g:pymode_rope_complete_on_dot = 0
    let g:pymode_rope_regenerate_on_write = 0
  '';

  services.emacs.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 2;

  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  nix.maxJobs = 8;
  nix.buildCores = 8;
}
