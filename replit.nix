{ pkgs }: {
    deps = [
      pkgs.htop-vim
        pkgs.bashInteractive
        pkgs.man
        pkgs.caddy
        pkgs.tmux
        pkgs.jre8
    ];
}