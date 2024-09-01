{
  description = "WhoseDefaultBrowser Swift project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      packages = forAllSystems (system:
        let 
          pkgs = nixpkgsFor.${system};
        in {
          default = pkgs.stdenvNoCC.mkDerivation {
            pname = "WhoseDefaultBrowser";
            version = "1.0.0";
            src = ./.;
            buildInputs = [ pkgs.darwin.apple_sdk.frameworks.CoreServices ];
            buildPhase = ''
              export PATH=$PATH:/usr/bin:/usr/local/bin
              export SDKROOT=$(xcrun --show-sdk-path)
              export MACOSX_DEPLOYMENT_TARGET=10.15
              xcrun swiftc -o WhoseDefaultBrowser main.swift
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
