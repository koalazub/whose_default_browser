{
  description = "WhoseDefaultBrowser Swift project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      supportedSystems = [
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.stdenvNoCC.mkDerivation {
            pname = "WhoseDefaultBrowser";
            version = "1.0.0";
            src = builtins.path {
              path = ./.;
              name = "source";
            };
            buildInputs = [ pkgs.darwin.apple_sdk.frameworks.CoreServices ];
            buildPhase = ''
              export PATH="/usr/bin:/usr/local/bin:$PATH"

              # Use the latest SDK and Swift from the system's Xcode
              export SDKROOT=$(/usr/bin/xcrun --sdk macosx --show-sdk-path)
              export DEVELOPER_DIR=$(/usr/bin/xcode-select -p)
              export MACOSX_DEPLOYMENT_TARGET=15.0

              # Use xcodebuild for compilation (compatible with macOS 26+ Xcode)
              /usr/bin/xcrun --sdk macosx swiftc \
                -o WhoseDefaultBrowser \
                -sdk "$SDKROOT" \
                -target ${if system == "aarch64-darwin" then "arm64" else "x86_64"}-apple-macosx15.0 \
                main.swift
            '';
            installPhase = ''
              mkdir -p $out/bin
              install -D WhoseDefaultBrowser $out/bin/WhoseDefaultBrowser
            '';
          };
        }
      );
    };
}
