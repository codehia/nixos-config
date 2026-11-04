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
    default_stages = [ "pre-commit" ];
    hooks = {
      stylua.enable = true;
      nixfmt.enable = true;
      mirror-push = {
        enable = true;
        name = "Post Commit push to mirror repo";
        # Fails the hook (commit itself is kept) so a failed mirror push is visible.
        entry = "${pkgs.writeShellScript "mirror-push" ''
          echo "Commit successful. Pushing mirror to GitHub..."
          if ${pkgs.git}/bin/git push git@github.com:codehia/nixos-config.git -f --mirror; then
            echo "Completed the push to GitHub mirror."
          else
            echo "WARNING: GitHub mirror push FAILED. Retry: git push git@github.com:codehia/nixos-config.git -f --mirror" >&2
            exit 1
          fi
        ''}";
        stages = [ "post-commit" ];
        pass_filenames = false;
        always_run = true;
      };
      check-upstream = {
        enable = true;
        name = "Check for unpulled upstream changes";
        entry = "./.githooks/pre-commit";
        stages = [ "pre-commit" ];
        pass_filenames = false;
        always_run = true;
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
