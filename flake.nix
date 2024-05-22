{
  description = "Verdaccio (bun)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        bun = pkgs.bun;
      in
      {
        packages.verdaccio = pkgs.stdenv.mkDerivation rec {
          pname = "verdaccio";
          version = "5.31.0";
          nativeBuildInputs = [ bun pkgs.makeBinaryWrapper ];
          dontConfigure = true;
          dontBuild = true;
          dontStrip = true;

          src = [
            ./verdaccio.js
            ./package.json
            ./bun.lockb
          ];

          unpackPhase = ''
            mkdir -p $out/bin
            for srcFile in $src; do
              cp $srcFile "$out/$(stripHash $srcFile)"
            done
          '';

          installPhase = ''
            cd $out
            bun install --no-progress --no-cache --frozen-lockfile
            makeBinaryWrapper ${bun}/bin/bun $out/bin/${pname} \
              --add-flags "run --bun --prefer-offline --no-install $out/verdaccio.js"
          '';
        };

        devShell = pkgs.mkShell {
          buildInputs = [ bun ];
        };
      });
}
