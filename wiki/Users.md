# Adding a new user

## 1. Create the user aspect

```bash
touch modules/users/newuser.nix
git add modules/users/newuser.nix
```

```nix
# modules/users/newuser.nix
{ den, ... }:
{
  den.aspects.newuser = {
    includes = [
      den.provides.primary-user       # uid 1000 + wheel — drop this for secondary users
      (den.provides.user-shell "fish")

      # Theming
      den.aspects.appearance          # stylix + catppuccin (combined)

      # Terminal / shell
      den.aspects.terminal            # ghostty, kitty, fish, tmux

      # Editor / dev
      den.aspects.vcs                 # git, lazygit, direnv
      den.aspects.editor              # nvim + vscode

      # Browser
      den.aspects.browser

      # Secrets / SSH
      den.aspects.secrets
      den.aspects.ssh

      # Packages and tools
      den.aspects.packages
      den.aspects.shell-tools         # bat, eza, fzf, yazi, zoxide, ...
      den.aspects.tui
      den.aspects.cli-utils
      den.aspects.apps                # graphical app bundles

      # Desktop shell
      den.aspects.dms-home
    ];

    nixos.users.users.newuser = {
      description = "Full Name";
      initialPassword = "changeme";
    };

    homeManager.home.homeDirectory = "/home/newuser";
    homeManager.programs.git.settings.user = {
      name = "Full Name";
      email = "user@example.com";
    };
  };
}
```

## 2. Add the user to the relevant hosts

```nix
# modules/hosts/workstation/default.nix
den.hosts.x86_64-linux.workstation = {
  ...
  users.newuser = {
    nvimLanguages = [ "nix" "python" ];
  };
};
```

## 3. Set up their SSH key

See [[Secrets#Add a user SSH key]].

## 4. Build

```bash
just install
```
