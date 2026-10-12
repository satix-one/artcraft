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
      devShells = forEachSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ (import rust-overlay) ];
          };

          # Используем стабильный Rust с поддержкой необходимых таргетов (включая WASM для веб-версии)
          rustToolchain = pkgs.rust-bin.stable.latest.default.override {
            extensions = [ "rust-src" "rustfmt" "clippy" ];
            targets = [ "wasm32-unknown-unknown" ];
          };
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              # Компилятор и инструменты Rust
              rustToolchain
              pkg-config
              
              # Инструменты для сборки веб-версии (если используется Trunk)
              trunk
              wasm-bindgen-cli

              # Системные зависимости для графических библиотек и оконных менеджеров в Linux (Wayland / X11)
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
              
              # Графические библиотеки (GTK / GLib / Cairo / Pango часто требуются GUI-фреймворкам на Rust)
              gtk3
              glib
              cairo
              pango
              atk
              gdk-pixbuf

              # Дополнительные системные утилиты
              openssl
              udev
            ];

            # Переменные окружения для корректной работы компилятора и линковщика с графическими библиотеками
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
