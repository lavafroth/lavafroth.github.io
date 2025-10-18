{
  description = "build lavafroth.is-a.dev locally";
  outputs =
    {
      nixpkgs,
      ...
    }:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            hugo
            (writeScriptBin "serve" ''
              ${pkgs.hugo}/bin/hugo -D
              ${pkgs.pagefind}/bin/pagefind --output-path "static/pagefind"
              ${pkgs.hugo}/bin/hugo server -D
            '')
          ];
        };
      });
    };
}
