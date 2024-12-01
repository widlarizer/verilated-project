{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    verilator
    perl
    gcc
    gnumake
    zig
    zls
    spade
    surfer
  ];
  shellHook = ''
    export VERILATOR_ROOT=${pkgs.verilator}/share/verilator
  '';
}
