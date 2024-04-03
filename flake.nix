{
  description = "WhoseDefaultBrowser Swift project package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

      buildWhoseDefaultBrowser = { system }:
        let
          pkgs = nixpkgsFor.${system};
        in pkgs.stdenv.mkDerivation {
          name = "WhoseDefaultBrowser";
          src = ./.;
          buildInputs = with pkgs; [ swift ];

          buildPhase = ''
            swiftc -o $name WhoseDefaultBrowser.swift
          '';

          installPhase = ''
            mkdir -p $out/bin
            mv WhoseDefaultBrowser $out/bin/
          '';
        };
      
    in {
      packages = forAllSystems (system: {
        WhoseDefaultBrowser = buildWhoseDefaultBrowser { inherit system; };
      });

      devShells = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              swift
            ];

            shellHook = ''
              echo "Development environment for WhoseDefaultBrowser is ready."
              echo "Swift version: $(swift --version)"
            '';
          };
        });

      defaultPackage = forAllSystems (system: self.packages.${system}.WhoseDefaultBrowser);
    };
}
