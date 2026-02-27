{ pkgs, ... }:
{
  packages = with pkgs; [ git ];
  languages = {
    lua = {
      enable = true;
      lsp.enable = true;
    };
    nix = {
      enable = true;
      lsp.enable = true;
    };
  };

  git-hooks = {
    enable = true;
    default_stages = [
      "pre-commit"
      "post-commit"
      "commit-msg"
    ];
    hooks = {
      stylua.enable = true;
      nixfmt.enable = true;
      mirror-push = {
        enable = true;
        name = "Post Commit push to mirror repo";
        entry = "./.githooks/post-commit";
        stages = [ "post-commit" ];
        pass_filenames = false;
      };
      prepend-hostname = {
        enable = true;
        name = "Prepend hostname to commit message";
        entry = "./.githooks/commit-msg";
        stages = [ "commit-msg" ];
      };
    };
  };
}
