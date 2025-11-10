{ pkgs, inputs, ... }: {
  fonts = {
    fontconfig = {
      enable = true;
      antialias = true;
      hinting = {
        enable = true;
        style = "slight";
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
        <fontconfig>
          <alias>
            <family>sans-serif</family>
            <prefer>
              <family>SF Pro</family>
              <family>Symbols Nerd Font</family>
            </prefer>
          </alias>
          
          <alias>
            <family>monospace</family>
            <prefer>
              <family>SF Mono</family>
              <family>Symbols Nerd Font</family>
            </prefer>
          </alias>
          
          <alias>
            <family>SF Pro</family>
            <prefer>
              <family>SF Pro</family>
              <family>Symbols Nerd Font</family>
            </prefer>
          </alias>

          <alias>
            <family>SF Mono</family>
            <prefer>
              <family>SF Mono</family>
              <family>Symbols Nerd Font</family>
            </prefer>
          </alias>
        </fontconfig>
      '';
    };
    packages = (with pkgs; [
      dejavu_fonts
      fira-code
      fira-code-symbols
      font-awesome
      hackgen-nf-font
      ibm-plex
      inter
      jetbrains-mono
      material-icons
      maple-mono.NF
      minecraftia
      nerd-fonts.im-writing
      nerd-fonts.blex-mono
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
      noto-fonts-emoji
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-monochrome-emoji
      powerline-fonts
      roboto
      roboto-mono
      #symbola
      terminus_font
    ]) ++ (with inputs; [ apple-fonts.packages.${pkgs.system}.sf-pro ]);
  };
}
