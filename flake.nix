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

            # Укажите правильный cargoLock, если у вас есть Cargo.lock,
            # либо используйте vendorHash, если зависимости скачиваются через сети.
            # Для начала можно попробовать закомментировать vendorHash, если Cargo.lock на месте,
            # либо использовать lib.fakeHash для получения актуального хэша.
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
              xorg.libX11
              xorg.libXcursor
              xorg.libXi
              xorg.libXrandr
              gtk3
              glib
              cairo
              pango
              atk
              gdk-pixbuf
              openssl
              udev
            ];

            meta = {
              description = "Open Source Raster Graphics Editor written in Rust";
              homepage = "https://github.com/satix-one/artcraft";
              license = pkgs.lib.licenses.mit; # поправьте, если другая лизензия
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
              xorg.libX11
              xorg.libXcursor
              xorg.libXi
              xorg.libXrandr
              gtk3
              glib
              cairo
              pango
              atk
              gdk-pixbuf
              openssl
              udev
            ];

            shellHook = ''
              export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [
                pkgs.libglvnd
                pkgs.vulkan-loader
                pkgs.libxkbcommon
                pkgs.wayland
                pkgs.xorg.libX11
                pkgs.xorg.libXcursor
                pkgs.xorg.libXi
                pkgs.xorg.libXrandr
                pkgs.fontconfig
                pkgs.freetype
              ]}:$LD_LIBRARY_PATH"
              
              echo "PhotoCraft Nix Environment Loaded 🚀"
              rustc --version
              cargo --version
            '';
          };
        });
    };
}
