# Practical Learning Path

A structured path from "I just use this config" to "I can build and debug anything in it."
Each phase has a clear goal, resources, and a hands-on exercise.

---

## Phase 1 — Nix language (1–2 weeks)

**Goal:** Read and write any `.nix` expression without confusion.

**What to focus on:**
- Types, functions, `let/in`, `inherit`, `with`
- The `//` merge operator and `?` has-attr operator
- `lib.mkIf`, `lib.optionals`, `lib.optionalAttrs`
- `builtins.trace` for debugging
- Understanding lazy evaluation (why your trace might not fire)

**Resources:**
- [nix.dev — Nix language tutorial](https://nix.dev/tutorials/nix-language) — best beginner intro
- `notes/nix-language.md` in this repo

**Exercise:**
Open `just repl` and evaluate expressions:
```nix
nix-repl> let x = 10; in x * 2
nix-repl> { a = 1; } // { b = 2; }
nix-repl> builtins.filter (x: x > 2) [ 1 2 3 4 5 ]
nix-repl> lib.optionalAttrs true { foo = 1; }
```
Then open any aspect file (e.g. `modules/aspects/fish.nix`) and read it top to bottom
without looking anything up. If something is unclear, look it up in the language docs.

---

## Phase 2 — NixOS module system (1–2 weeks)

**Goal:** Understand how modules merge, what options/config mean, and how to resolve conflicts.

**What to focus on:**
- Module function signature `{ config, pkgs, lib, ... }:`
- `options` vs `config` blocks
- How list options merge (automatic concatenation)
- `lib.mkForce`, `lib.mkDefault` for priority
- Reading `config.*` to make conditional config
- What Home Manager is and how it mirrors NixOS modules

**Resources:**
- [nixos.org — Writing NixOS modules](https://nixos.org/manual/nixos/stable/#sec-writing-modules)
- [nix.dev — Module system deep dive](https://nix.dev/tutorials/module-system/module-system)
- `notes/module-system.md` in this repo

**Exercise:**
Pick any NixOS option you use (e.g. `programs.fish.enable`) and trace it:
1. Search nixpkgs for where it's declared: `grep -r "programs.fish" /run/current-system/`
2. Find the option definition — what type is it? What does it default to?
3. In `just repl`, inspect: `nixosConfigurations.workstation.config.programs.fish`

---

## Phase 3 — Flakes (a few days)

**Goal:** Understand what `flake.nix` and `flake.lock` do, why they exist, and how inputs flow.

**What to focus on:**
- Inputs and outputs structure
- `flake.lock` — what it pins and why
- `inputs.X.follows` — when to use it and the cache tradeoff
- flake-parts — why it exists (module system for flake outputs)
- flake-file — how this config declares inputs inline

**Resources:**
- [nix.dev — Flakes introduction](https://nix.dev/concepts/flakes)
- `notes/flakes.md` in this repo

**Exercise:**
Run `just dry` and look at the first few lines of output — it shows which flake inputs
are being used. Then run `just upp i=home-manager` and watch `flake.lock` update.
Compare `git diff flake.lock` to see which commit hash changed.

---

## Phase 4 — Den framework (1 week)

**Goal:** Add, modify, and debug aspects confidently. Understand why context dispatch works.

**What to focus on:**
- Aspects: `nixos`, `homeManager`, `includes` keys
- Context dispatch: `{ host, ... }` vs `{ host, user, ... }` — what gets skipped and why
- `den.lib.perHost` / `den.lib.perUser` — when and why to use them
- Collector pattern — multiple files, same aspect name
- `den._.to-users` / `den._.to-hosts` — cross-direction config
- The silent failure modes (perUser in host includes, HM without schema.user.classes)

**Resources:**
- `notes/den.md` in this repo
- `notes/dendritic-pattern.md` in this repo
- `wiki/Den-Framework.md`
- CLAUDE.md — the critical gotchas section

**Exercises:**
1. Add a new user-level package: add it to `modules/aspects/shell-tools/` or similar,
   `git add` it, run `just dry` to verify it would install.
2. Make a config vary by host: add an attr to a host declaration, read it with `den.lib.perHost`.
3. Break something intentionally: remove `systemd.enable = false` from the Hyprland HM
   config, run `just dry --show-trace`, read the error.

---

## Phase 5 — Daily use (ongoing)

**Goal:** Self-sufficient — look things up, don't guess.

**The lookup habit:**
| Task | Where to look |
|------|-------------|
| "Does option X exist?" | [search.nixos.org](https://search.nixos.org) (NixOS options) or [home-manager option search](https://home-manager-options.extranix.com) |
| "What package provides binary X?" | [search.nixos.org/packages](https://search.nixos.org/packages) |
| "How does den do X?" | Clone den to `/tmp/den`, read `templates/ci/modules/features/` |
| "Why isn't my config applying?" | `just repl` → inspect the value directly |
| "Build is failing with a trace" | `just debug`, read bottom-up |

**The debugging loop:**
```
something is wrong
    → just dry           (evaluation error? read it bottom-up)
    → just debug         (add --show-trace for full stack)
    → just repl          (inspect the value that should have changed)
    → builtins.trace     (add print to confirm a value at evaluation time)
    → git diff           (what did I actually change?)
```

---

## What "done" looks like

You're independent when you can:

- [ ] Add a new program to your config without looking at existing aspects for syntax
- [ ] Read a NixOS option search result and translate it directly into an aspect
- [ ] Diagnose a "value silently not applied" bug using the REPL
- [ ] Add a new flake input, regenerate `flake.nix`, understand why `follows` matters
- [ ] Explain to someone else why `mkIf` is wrong inside an aspect

You don't need to memorise option names — that's what search is for. The goal is
understanding the plumbing well enough that you can always find the right place to make
any change.
