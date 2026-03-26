# How to Read Documentation

A checklist for approaching any new library, tool, or system.

---

## Checklist

- [ ] **Find the shape** — what are the moving parts and how do they connect? Skim headings, diagrams, overview sections. Draw a rough box diagram (even if wrong).
- [ ] **Ask "why does this exist?"** — what problem does it solve? What would break without it? The answer usually makes the docs half-redundant.
- [ ] **Trace one real example end to end** — not the hello world in the docs. A real usage in your config or a real project. Read that one file completely.
- [ ] **Find the seams** — where does this library's output touch your code? What does it give you, what does it expect from you? That boundary is where bugs live.
- [ ] **Use your real code as ground truth** — if docs don't match what you see in files, look harder. Real code beats docs; docs can be outdated or wrong.
- [ ] **Test your mental model** — can you explain it in plain language? Can you predict what an undocumented edge case will do? That's when you've got it.
- [ ] **Write a `.notes/` file while learning** — not for later reference, but as the learning tool itself. Writing forces you to find the shape and trace the seams.

---

## The Goal

You're not building a reference map (memorising options). You're building a mental model good enough to *predict* behaviour without checking docs again.

---

## Notes on Each Step

### Find the shape first
Details have nowhere to land without the skeleton. For den/dendritic, the key shape was:
```
aspect → flake-file.inputs (auto-merged) → nixos / homeManager / includes
```
Once that was clear, every detail fit somewhere.

### One concrete example > full API
Pick the simplest real usage — in your own config if possible. Trace it completely. Look up only what you don't understand. This beats reading the full spec every time.

### Why > What
Documentation tells you *what*. The useful question is *why*. Example: age replaced GPG in sops because GPG is complex, stateful, and has a keyring daemon. Once you know that, age's entire design makes sense without reading its docs carefully.

### Seams are where understanding breaks down
For sops-nix in this config, the seam was `flake-file.inputs.sops-nix` inside an aspect feeding `inputs.sops-nix.nixosModules.sops` via `imports`. That join between two systems is where bugs live and where docs are least helpful — you have to read both sides.

### Learn by coding, not by reading
Write the smallest possible thing that uses the library in your actual project. Get it working. Then read the docs to understand what you just did. Verification of a working thing is faster than building understanding in the abstract.
