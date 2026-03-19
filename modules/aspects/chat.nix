{
  den.aspects.chat = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          # telegram-desktop # build failing on 6.4.1, skip until nixpkgs updates
          signal-desktop-bin
        ];
      };
  };
}
