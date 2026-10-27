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
timestamps as ints. Treat `time` as a Coil module root only (HostInvoke clocks;
no `libtime` dload). This package's `coil.toml` pins a trusted path dep at
`.ci/coil-time` (CI checkout). Sibling checkout is the same shape with
`../coil-time`. Pass `--root .ci/coil-time/src` (CLI `--root`; the compiler does
not follow `[module] roots` or path deps for discovery). Do not pass
`--allow-dload time` and do not put a native search path on `[ffi]`.

## Language repo checkout

[coil-lang](https://github.com/ardax-corp/coil-lang) does not vendor this tree.
Clone it as a sibling (`../coil-stdlib`) or under `coil-lang/.deps/coil-stdlib`.
Its workspace `coil.toml` lists those roots for spool; with plain `coil`, pass `--root ../coil-stdlib/src`.

Manifest schema (read by spool, not by `coil`): [project config](https://github.com/ardax-corp/coil-website/blob/main/src/content/docs/references/project-config.md).
`spool` vs `coil package`: [spool README](https://github.com/ardax-corp/spool).
