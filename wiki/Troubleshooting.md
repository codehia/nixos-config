# Troubleshooting

## Ghostty service fails with `Result: protocol`

**Symptom:** `systemctl --user status app-com.mitchellh.ghostty.service` shows
`Active: failed (Result: protocol)`.

**Cause:** A stray Ghostty process holds the D-Bus name `com.mitchellh.ghostty`. When the
service starts with `--gtk-single-instance=true`, it detects the name is taken and exits
cleanly (status=0) without sending `READY=1`. systemd waits for that signal and reports
`protocol` failure.

**Debug:**
```bash
systemctl --user status app-com.mitchellh.ghostty.service
pgrep -a ghostty
```

**Fix:**
```bash
pkill ghostty
systemctl --user start app-com.mitchellh.ghostty.service
```

**Prevention:** Always launch Ghostty via the service or D-Bus activation, never directly
from a launcher or shell.

---

## Ghostty shows random black/blank lines

**Symptom:** Specific rows go completely black, obscuring text. Same rows affected
consistently within a session.

**Cause:** Stale fontconfig cache entries pointing to old nix store paths (garbage
collected after `just clean`). journald shows:

```
warning(generic_renderer): error building row y=N err=error.CannotOpenResource
```

**Debug:**
```bash
journalctl --user -u app-com.mitchellh.ghostty.service --no-pager -n 50 | grep CannotOpen
fc-cache -f -v
```

**Fix:**
```bash
fc-cache -f
systemctl --user restart app-com.mitchellh.ghostty.service
```
