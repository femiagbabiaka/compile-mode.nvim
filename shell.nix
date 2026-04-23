{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = [
    pkgs.neovim
    pkgs.vimPlugins.plenary-nvim
    pkgs.stylua
  ];

  shellHook = ''
    export PLENARY_PATH="${pkgs.vimPlugins.plenary-nvim}"
  '';
}
