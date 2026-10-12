{
  description = "PhotoCraft - Open Source Raster Graphics Editor (Rust)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, rust-overlay, ... }@inputs:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forEachSystem = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forEachSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ (import rust-overlay) ];
          };

          rustToolchain = pkgs.rust-bin.stable.latest.default;
          rustPlatform = pkgs.makeRustPlatform {
            cargo = rustToolchain;
            rustc = rustToolchain;
          };
        in
        {
          default = rustPlatform.buildRustPackage {
            pname = "photocraft";
            version = "0.7.0";
            src = ./.;

            cargoLock.lockFile = ./Cargo.lock;

            nativeBuildInputs = with pkgs; [
              pkg-config
            ];

            buildInputs = with pkgs; [
              fontconfig
              freetype
              expat
              libglvnd
              vulkan-loader
              libxkbcommon
              wayland
              libx11
              libxcursor
              libxi
              libxrandr
              gtk3
              glib
              cairo
              pango
              atk
              gdk-pixbuf
              libsoup_3
              openssl
              udev
            ];

            meta = {
              description = "Open Source Raster Graphics Editor written in Rust";
              homepage = "https://github.com/satix-one/artcraft";
              platforms = supportedSystems;
            };
          };
        });

      devShells = forEachSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ (import rust-overlay) ];
          };

          rustToolchain = pkgs.rust-bin.stable.latest.default.override {
            extensions = [ "rust-src" "rustfmt" "clippy" ];
            targets = [ "wasm32-unknown-unknown" ];
          };
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              rustToolchain
              pkg-config
              trunk
              wasm-bindgen-cli
              fontconfig
              freetype
              expat
              libglvnd
              vulkan-loader
              libxkbcommon
              wayland
              libx11
              libxcursor
              libxi
              libxrandr
              gtk3
              glib
              cairo
              pango
              atk
              gdk-pixbuf
              libsoup_3
              openssl
              udev
            ];

            shellHook = ''
              export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [
                pkgs.libglvnd
                pkgs.vulkan-loader
                pkgs.libxkbcommon
                pkgs.wayland
                pkgs.libx11
                pkgs.libxcursor
                pkgs.libxi
                pkgs.libxrandr
                pkgs.fontconfig
                pkgs.freetype
                pkgs.libsoup_3
              ]}:$LD_LIBRARY_PATH"
              
              echo "PhotoCraft Nix Environment Loaded 🚀"
            '';
          };
        });
    };
}
