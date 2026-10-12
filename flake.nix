{
  description = "ArtCraft / PhotoCraft - photo editor written in Rust (Tauri workspace)";

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
          libX11
          libXcursor
          libXrandr
          libXi
          fontconfig
          freetype
          glib
          gtk3
          cairo
          pango
          libsoup_3    
          webkitgtk_4_1
          openssl
          cmake
          rustc
          pkg-config
          makeWrapper 
          llvm
          clang
          ninja
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
          version = "0.1.0";

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
