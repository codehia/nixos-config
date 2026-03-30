# Rust Learning Path — Learn by Doing

## Phase 1 — Get Punched in the Face by the Compiler
Goal: understand ownership, borrowing, and the type system by fighting the compiler.

Build these in order. No tutorials — write it, hit errors, read what the compiler says, fix it:

1. **CLI calculator** — takes args like `calc 3 + 4`, prints result.
   Teaches: `std::env::args`, parsing, `match`, `Result`, basic structs

2. **File word counter** — reads a file, counts words/lines/chars (like `wc`).
   Teaches: file I/O, `BufReader`, iterators, `HashMap`

3. **Todo list CLI** — add/remove/list todos saved to a JSON file.
   Teaches: `serde`+`serde_json`, `Vec`, enums, writing/reading files

4. **HTTP status checker** — takes a list of URLs from a file, checks if each returns 200.
   Teaches: `reqwest` (async), `tokio`, `async/await`

Rule: when you hit a borrow checker error, don't just add `.clone()` to make it go away.
Understand *why* it's complaining first.

---

## Phase 2 — Own the Hard Parts
Goal: lifetimes, traits, iterators — the things that separate Rust from other languages.

5. **Grep clone** — `mygrep <pattern> <file>`, with `-i` for case-insensitive, `-n` for line numbers.
   Teaches: lifetimes, `regex` crate, traits

6. **INI/TOML config parser** — parse a simple config file format into a struct yourself (no `toml` crate yet).
   Teaches: `impl Trait`, custom iterators, `&str` vs `String` deeply

7. **Thread pool** — a simple worker pool that processes jobs from a queue.
   Teaches: `Arc`, `Mutex`, `mpsc` channels, threads — concurrency fundamentals

---

## Phase 3 — Systems Level
Goal: understand memory, unsafe, FFI — needed for Wayland work.

8. **ls clone** — list directory contents with `-l`, `-a`, `-R`.
   Teaches: `std::fs`, `os::unix` extensions, formatting output

9. **Simple shell** — a REPL that runs commands, handles `cd`, pipes (`|`), and basic redirects.
   Teaches: `std::process`, fork/exec concepts, signal handling

10. **D-Bus hello world** — using `zbus`, connect to the session bus, call
    `org.freedesktop.DBus.ListNames`, print all running services. Then: read battery
    percentage from UPower.
    Teaches: async D-Bus, the `zbus` API

---

## Phase 4 — Build the Real Thing
Goal: write an actual Wayland/D-Bus backend service that Quickshell can talk to.

11. **Network status daemon** — watch NetworkManager over D-Bus, expose current wifi SSID,
    signal strength, and connection state on a Unix socket or custom D-Bus interface.

12. **Audio control service** — talk to PipeWire/PulseAudio over D-Bus, expose get/set
    volume and mute toggle.

---

## Resources — Only When Stuck

- [The Rust Book](https://doc.rust-lang.org/book/) — read the chapter *after* hitting the concept in code, not before
- [Rustlings](https://github.com/rust-lang/rustlings) — small compiler exercises, good for Phase 1 gaps
- `rustc` error messages — Rust has the best compiler errors of any language; read them fully
- [zbus docs](https://dbus2.github.io/zbus/) — for Phase 3 onwards

---

## The One Rule

Write the code first. Only look things up when the compiler or your own ignorance fully
blocks you. The frustration is the learning.
