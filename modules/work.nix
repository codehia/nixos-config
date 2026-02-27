{den, ...}: {
  den.aspects.work = {
    includes = [den.aspects.zoom];
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.slack];
    };
  };
}
