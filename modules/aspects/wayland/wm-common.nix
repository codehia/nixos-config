# Settings shared by every WM. den.aspects.wm-configs reaches every user via
# den.default, so this applies whichever compositor is picked at the greeter.
{
  # Electron/Chromium apps run natively on Wayland under all compositors.
  den.aspects.wm-configs.homeManager.home.sessionVariables.NIXOS_OZONE_WL = "1";
}
