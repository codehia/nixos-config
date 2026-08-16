{
  den.aspects.shell-tools = {
    # ipython has no HM module. IPYTHONDIR (home-manager.nix) already points at
    # ~/.config/ipython, so this file is read by every ipython on the system —
    # devenv, uv, nix shell, venv.
    homeManager.xdg.configFile."ipython/profile_default/ipython_config.py".text = ''
      c = get_config()  # noqa

      # 24-bit colour instead of prompt_toolkit's 256-colour default. This is what
      # fixed the invisible completion-dropdown text.
      c.TerminalInteractiveShell.true_color = True

      # Never set highlighting_style: inert since 9.0, and any pygments name makes
      # ipython fail to start (ipython/ipython#14832).

      # Editing.
      c.TerminalInteractiveShell.autoindent = True
      c.TerminalInteractiveShell.auto_match = True

      # Startup/exit noise.
      c.TerminalIPythonApp.display_banner = False
      c.TerminalInteractiveShell.enable_tip = False
      c.TerminalInteractiveShell.confirm_exit = False
      c.TerminalInteractiveShell.term_title_format = "ipython: {cwd}"

      c.InteractiveShell.history_length = 50000
    '';
  };
}
