# DMS IPC keybinds shared by every WM (hyprland, swayfx, mango).
# `_` prefix: not auto-imported; each WM file imports this and maps it to its own
# bind syntax. mods: "none" | "super" | "super+shift". key: lowercase keysym.
[
  {
    mods = "super";
    key = "space";
    cmd = "dms ipc launcher toggle";
  }

  # Media / brightness
  {
    mods = "none";
    key = "F1";
    cmd = "dms ipc audio mute";
  }
  {
    mods = "none";
    key = "F2";
    cmd = "dms ipc audio decrement 5";
  }
  {
    mods = "none";
    key = "F3";
    cmd = "dms ipc audio increment 5";
  }
  {
    mods = "none";
    key = "F4";
    cmd = "dms ipc audio micmute";
  }
  {
    mods = "none";
    key = "F5";
    cmd = "dms ipc brightness decrement 10 backlight:amdgpu_bl1";
  }
  {
    mods = "none";
    key = "F6";
    cmd = "dms ipc brightness increment 10 backlight:amdgpu_bl1";
  }

  # DMS toggles
  {
    mods = "super+shift";
    key = "p";
    cmd = "dms ipc powermenu toggle";
  }
  {
    mods = "super+shift";
    key = "d";
    cmd = "dms ipc notifications toggleDoNotDisturb";
  }
  {
    mods = "super+shift";
    key = "i";
    cmd = "dms ipc notepad toggle";
  }
  {
    mods = "super+shift";
    key = "v";
    cmd = "dms ipc clipboard toggle";
  }
  {
    mods = "super+shift";
    key = "b";
    cmd = "dms ipc notifications toggle";
  }
  {
    mods = "super+shift";
    key = "g";
    cmd = "dms ipc control-center toggle";
  }
]
