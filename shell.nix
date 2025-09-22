{
  pkgs ? import <nixpkgs> { }
}:
let
  overrides = (builtins.fromTOML (builtins.readFile ./rust-toolchain.toml));
in
pkgs.callPackage (
  {
    stdenv
  , lib
  , pkgs
  , mkShell
  , rustup
  , rustPlatform
  , clang
  , lld
  , pkg-config
  , libGL
  , libX11
  , libxcb
  , libxcb-wm
  , libxcursor
  , alsa-lib
  , libjack2
  }:
  mkShell {
    strictDeps = true;
    nativeBuildInputs = [
      (pkgs.pkgsCross.mingwW64.buildPackages.gcc.override { 
        extraBuildCommands = ''
          printf '%s' '-L${pkgs.pkgsCross.mingw32.windows.mcfgthreads}/lib' >> $out/nix-support/cc-ldflags
          printf '%s' '-I${pkgs.pkgsCross.mingw32.windows.mcfgthreads.dev}/include' >> $out/nix-support/cc-cflags
        '';
      })
      rustup
      rustPlatform.bindgenHook
      pkg-config
      lld
      libjack2
    ];
    # libraries here
    buildInputs = [
      (pkgs.pkgsCross.mingwW64.windows.mcfgthreads.overrideAttrs {
        dontDisableStatic = true;
      })
      pkgs.pkgsCross.mingwW64.windows.pthreads
      libGL
      libX11
      libxcb
      libxcb-wm
      libxcursor
      alsa-lib
    ];
    RUSTC_VERSION = overrides.toolchain.channel;
    # https://github.com/rust-lang/rust-bindgen#environment-variables
    shellHook = ''
      export PATH="''${CARGO_HOME:-~/.cargo}/bin":"$PATH"
      export PATH="''${RUSTUP_HOME:-~/.rustup}/toolchains/$RUSTC_VERSION-${stdenv.hostPlatform.rust.rustcTarget}/bin":"$PATH"
    '';
  }
) { }