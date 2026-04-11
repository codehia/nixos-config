# Commands

```bash
just install         # build and apply
just test            # activate temporarily, no boot entry
just dry             # preview what would change, nothing applied
just debug           # apply with full trace (good for debugging build failures)
just up              # update all flake inputs and rebuild
just upp i=NAME      # update one input, e.g. just upp i=home-manager
just clean           # garbage collect old generations
just write-flake     # regenerate flake.nix after adding/removing flake inputs
just history         # list past generations
```

> Never use `nix eval` or `nix repl` directly — causes a RAM spike. Use `just dry` instead.
