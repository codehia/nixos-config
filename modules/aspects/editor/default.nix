{ den, ... }:
{
  den.aspects.editor = {
    includes = [
      den.aspects.nvim
      (den._.unfree [ "vscode" ])
    ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs.unstable; [
          vscode
        ];
      };
  };
}
