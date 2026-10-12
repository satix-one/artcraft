{
  description = "ArtCraft / PhotoCraft - photo editor written in Rust";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        buildInputs = with pkgs; [
          libxkbcommon
          libGL
          wayland
          xorg.libX11
          xorg.libXcursor
          xorg.libXrandr
          xorg.libXi
          fontconfig
          freetype
          glib  
      ];

        nativeBuildInputs = with pkgs; [
          cargo
          rustc
          pkg-config
          makeWrapper
        ];
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "artcraft";
          version = "0.1.0"; # подставьте нужную версию или берите из Cargo.toml

          src = ./.;

          cargoLock = {
            lockFile = ./Cargo.lock;
          };

          inherit nativeBuildInputs buildInputs;

          postInstall = ''
            wrapProgram $out/bin/artcraft \
              --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath buildInputs}"
          '';
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.default ];
          buildInputs = with pkgs; [
            rust-analyzer
            clippy
            rustfmt
          ];
          shellHook = ''
            export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath buildInputs}:$LD_LIBRARY_PATH"
          '';
        };
      });
}
