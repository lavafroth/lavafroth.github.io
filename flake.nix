{
  description = "build lavafroth.is-a.dev locally";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in
        {
          devShells.default = pkgs.mkShell {
            packages = with pkgs;
            [
              hugo
              (writeScriptBin "serve" ''
                ${pkgs.hugo}/bin/hugo -D
                ${pkgs.pagefind}/bin/pagefind --output-path "static/pagefind"
                ${pkgs.hugo}/bin/hugo server -D
              '')
            ];
          };
        }
      );
}
