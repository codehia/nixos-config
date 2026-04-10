# Code Exploration Techniques

How to navigate an unfamiliar codebase and figure out how things were meant to work.

---

## 1. Start with the entry point, not the middle

Before reading any source, find where the thing you care about *begins*:

- For a CLI tool: `main()`, `bin/`, or the script that gets run
- For a library: the public API surface (`index.ts`, `lib.rs`, `__init__.py`)
- For a config-driven system (like DMS): the settings schema and the loader that reads it

If you jump into the middle of a large file first, you'll spend time on implementation detail before you understand what it's supposed to do.

---

## 2. Follow the data, not the code

Pick the specific thing you're debugging (a setting, a value, a window) and trace it:

1. Where is it **declared/defined**? (schema, types, config file)
2. Where is it **read**? (the consumer)
3. Where is it **filtered or transformed**? (middleware, reducers, pipe stages)
4. Where does it **end up**? (the rendered output, the applied effect)

In the DMS example:
- `runningAppsCurrentWorkspace` declared in `dms-settings.json`
- Read in `RunningApps.qml` line 70
- Passed to `CompositorService.filterCurrentWorkspace()`
- Which calls `filterHyprlandCurrentWorkspaceSafe()` — the actual filter logic

Each step narrows the search space drastically.

---

## 3. Search for the exact string, not a concept

When you want to understand a specific setting or behaviour, grep for the exact key or identifier first — don't browse directories hoping to find it.

```bash
grep -r "runningAppsCurrentWorkspace" /tmp/dms
```

This immediately shows you every file that touches it. Read those files, not the whole repo.

For Nix configs specifically, use the `Grep` tool rather than `grep` directly — it respects gitignore and handles large trees better.

---

## 4. Check the tests before the implementation

Tests describe *intended* behaviour, not accidental behaviour. They are often easier to read than production code because they're concrete:

- What input goes in
- What output is expected
- What edge cases the author anticipated

In the den framework, the CI test suite at `templates/ci/modules/features/` is the most authoritative reference for how each feature is meant to work. Read a test before reading the implementation it tests.

---

## 5. Clone dependency repos to /tmp to read source

Never try to read source from `/nix/store` paths or guess at URLs. Clone the repo to `/tmp` and read files directly:

```bash
git clone https://github.com/owner/repo /tmp/repo
# Then read files normally, e.g. /tmp/repo/src/foo.qml
```

Always pull to get the latest before reading:

```bash
git -C /tmp/repo pull
```

This is cleaner than `nix eval`, avoids RAM spikes, and gives you a navigable file tree.

---

## 6. Read the schema/types before the logic

In typed systems, the schema tells you:

- What values are valid
- What the defaults are
- What the author considered important enough to expose as a setting

In QML/Quickshell: `SettingsData.qml` and `Common/SettingsData.qml`
In Nix: `schema.nix` and any `lib.mkOption` declarations
In TypeScript: interface/type definitions

Reading the schema first prevents you from misinterpreting what a field does.

---

## 7. Use `files_with_matches` first, then read selectively

When exploring a large repo, don't read whole files upfront. First find which files are relevant:

```bash
# Which files mention this concept?
grep -rl "toplevel\|taskbar\|runningApp" /tmp/dms/quickshell
```

Then read only the most promising ones. In this repo that would be:
`RunningApps.qml`, `CompositorService.qml` — not all 30 matches.

---

## 8. Understand what "current workspace" means to the compositor

Different compositors model workspaces differently. In Hyprland:

- Regular workspaces: positive IDs (1, 2, 3...)
- Special workspaces (scratchpads): **negative** IDs (-99, etc.)

Any filter that compares `wsId === currentWorkspaceId` will silently exclude all scratchpad windows because negative IDs never match a regular workspace. This is the kind of implicit invariant that only becomes visible when you read the filter implementation, not the feature docs.

When something is mysteriously missing from a list, look for filter functions and check what values they consider valid.

---

## 9. Read commit messages and recent history

Before digging into source, check what changed recently:

```bash
git -C /tmp/repo log --oneline -20
git -C /tmp/repo log --oneline --all --grep="taskbar"
```

The bug you're chasing may already be fixed upstream, or the behaviour you're confused by may have been intentionally changed with an explanation in the commit message.

---

## 10. When stuck, find the simplest working example

If the docs are unclear and the source is complex, look for:

- Examples in `examples/` or `templates/`
- Tests that exercise the exact feature
- A minimal config that works, then diff it against yours

In this config: den's `templates/ci/modules/features/` has a working nix-unit test for every feature — these are the simplest possible examples of correct usage.
