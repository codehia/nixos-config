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

      den.aspects.catppuccin
      den.aspects.stylix
      den.aspects.fish
      den.aspects.ghostty
      den.aspects.git
      den.aspects.nvim
      den.aspects.secrets
      den.aspects.ssh
      den.aspects.shell-tools
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
