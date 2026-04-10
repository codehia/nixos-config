# Nix Language Basics

Nix is a purely functional, lazily evaluated language. It has no statements — everything
is an expression that evaluates to a value. There are no classes, no loops, no mutation.

---

## Types

```nix
# Strings
"hello"
"interpolated: ${someVar}"
''
  multiline string
  indentation stripped automatically
''

# Paths (no quotes — Nix treats these specially, copies to /nix/store when used)
/etc/nixos
./relative/path
<nixpkgs>            # looks up in NIX_PATH, avoid this in flakes

# Numbers & booleans
42
3.14
true
false
null

# Lists (space-separated, not commas)
[ 1 2 3 ]
[ "foo" "bar" pkgs.git ]

# Attribute sets (like objects/dicts)
{ name = "Alice"; age = 30; }
{ foo.bar.baz = 1; }   # shorthand for { foo = { bar = { baz = 1; }; }; }

# Functions (no "function" keyword — just arg: body)
x: x + 1
{ a, b }: a + b                         # destructuring
{ a, b ? 10 }: a + b                    # with default
{ a, ... }@args: a + args.b             # rest args (... required to accept extras)
```

---

## Key Operators

```nix
# Merge attrsets (right side wins on conflict)
{ a = 1; } // { b = 2; }   # → { a = 1; b = 2; }
{ a = 1; } // { a = 2; }   # → { a = 2; }

# Has attribute
attrs ? key        # → true or false
attrs.key or 42    # → attrs.key if it exists, else 42

# List concatenation
[ 1 2 ] ++ [ 3 4 ]  # → [ 1 2 3 4 ]
```

---

## `let … in`

Bind names locally. The only scoping construct in Nix.

```nix
let
  x = 10;
  y = x + 5;    # can reference earlier bindings
  double = n: n * 2;
in
double y         # → 30
```

---

## `inherit`

Shorthand for `name = name;` — pulls names from the current or a given scope.

```nix
let x = 1; y = 2;
in { inherit x y; }          # same as { x = x; y = y; }

{ inherit (pkgs) git curl; }  # same as { git = pkgs.git; curl = pkgs.curl; }
```

---

## `with`

Brings an attrset's keys into scope. Use sparingly — makes it hard to know where names
come from.

```nix
with pkgs; [ git curl htop ]   # instead of [ pkgs.git pkgs.curl pkgs.htop ]
```

---

## `if` / `assert`

```nix
if condition then valueA else valueB   # must have both branches

assert condition; value                # throws at eval time if false
```

---

## `rec` attrsets

Makes an attrset self-referential. Avoid — creates subtle ordering bugs. Use `let` instead.

```nix
rec { a = 1; b = a + 1; }   # works but fragile
# prefer:
let a = 1; in { inherit a; b = a + 1; }
```

---

## Library functions you'll use constantly

These live in `lib` (nixpkgs lib, available as `lib` in module args):

```nix
# Conditional config — only include if condition is true
lib.mkIf condition { services.foo.enable = true; }

# Optional list — returns [] if false
lib.optionals condition [ pkgs.foo pkgs.bar ]

# Optional attrset — returns {} if false
lib.optionalAttrs condition { services.foo.enable = true; }

# Priority overrides — for when two modules conflict
lib.mkForce value       # highest priority, wins over everything
lib.mkDefault value     # lowest priority, loses to any explicit set

# String helpers
lib.concatStringsSep ", " [ "a" "b" "c" ]   # → "a, b, c"
lib.toUpper "hello"                           # → "HELLO"
toString 42                                   # → "42"

# List helpers
lib.filter (x: x > 2) [ 1 2 3 4 ]           # → [ 3 4 ]
lib.map (x: x * 2) [ 1 2 3 ]                # → [ 2 4 6 ]
```

---

## Debugging: `builtins.trace`

The print statement of Nix. Prints to stderr during evaluation, returns the second argument unchanged.

```nix
builtins.trace "my value is: ${toString x}" x

# Shorthand from lib:
lib.traceVal x           # prints and returns x
lib.traceValSeq x        # forces deep evaluation before printing (for nested structures)
```

> Nix is lazy — `trace` only fires if the value it wraps is actually evaluated. If you
> put it in a branch that never gets reached, it won't print.

---

## Lazy evaluation

Nix only evaluates what it needs. This means:

- **Unused attrset keys are never evaluated** — no error even if they'd fail
- **Infinite data structures are possible** — as long as you don't traverse them fully
- **`builtins.trace` may not fire** — if the surrounding expression isn't needed

```nix
let x = abort "never evaluated";    # no error — x is never used
in { a = 1; b = x; }.a             # → 1, b is never evaluated
```

---

## Evaluation flow

```mermaid
flowchart TD
    A[".nix files"] -->|"Nix reads & parses"| B[AST]
    B -->|"Lazy evaluation"| C[Attribute tree]
    C -->|"Forced by build system"| D[Derivations]
    D -->|"nix-store --realise"| E[/nix/store/...]

    style A fill:#2d2d2d,color:#cdd6f4
    style B fill:#2d2d2d,color:#cdd6f4
    style C fill:#313244,color:#cba6f7
    style D fill:#313244,color:#89b4fa
    style E fill:#1e1e2e,color:#a6e3a1
```

**Phase 1 — Evaluation:** Nix reads all `.nix` files and produces an attribute tree. No
building happens. Most config errors surface here. Use `just dry` to check.

**Phase 2 — Instantiation:** Derivations (build recipes) are extracted and written to
`/nix/store/*.drv`. This locks down exactly what will be built and with what inputs.

**Phase 3 — Build:** Each `.drv` is realised — downloads happen, compilers run, outputs
land in `/nix/store/<hash>-<name>/`.
