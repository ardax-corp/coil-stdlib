# Consume coil-stdlib

Every spool project declares the stdlib as a dependency; there is no global
copy. `spool new` and `spool init` write it for you. spool passes the locked
checkout's **`src/`** as a module root, so imports are unprefixed (`use ascii`,
`use path::{Path}`); no `[module].roots` entry is needed.

## Via spool

```toml
[dependencies]
stdlib = { git = "https://github.com/ardax-corp/coil-stdlib.git", version = "latest" }
```

`version = "latest"` follows this repo's tip, locked to a commit in
`coil.lock`; spool warns until you pin it, because `spool update` can move a
project onto breaking changes. Pin a commit (this repo has no tags yet):

```bash
spool add stdlib --git https://github.com/ardax-corp/coil-stdlib.git --rev <commit SHA>
```

Each project locks its own stdlib version; projects on the same commit share
one cached checkout.

## Path / sibling checkout

```toml
[module]
roots = ["./src", "../coil-stdlib/src"]
```

`random::Rng::from_time` seeds from [coil-time](https://github.com/ardax-corp/coil-time)
timestamps as ints. `coil.toml` declares it as a git dependency
(`https://github.com/ardax-corp/coil-time.git`), so spool fetches it along with
stdlib. It is pure Coil: no `--allow-dload time` and no `[ffi]` search path.
With plain `coil`, clone coil-time and pass `--root ../coil-time/src` (the
compiler reads no `coil.toml`).

## Language repo checkout

[coil-lang](https://github.com/ardax-corp/coil-lang) does not vendor this tree.
Clone it as a sibling (`../coil-stdlib`) or under `coil-lang/.deps/coil-stdlib`.
Its workspace `coil.toml` lists those roots for spool; with plain `coil`, pass `--root ../coil-stdlib/src`.

Manifest schema (read by spool, not by `coil`): [project config](https://github.com/ardax-corp/coil-website/blob/main/src/content/docs/references/project-config.md).
`spool` vs `coil package`: [spool README](https://github.com/ardax-corp/spool).
