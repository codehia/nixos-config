{
  den.aspects.shell-tools = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          eza
          glow
          jq
          ripgrep
          yq-go
        ];
      };
  };
}
