# Consume coil-stdlib

Unprefixed imports (`use ascii`, `use path::{Path}`) need this package's **`src/`**
as a module root — not the parent `.spool/deps` folder. `spool` links
`.spool/deps/stdlib` at `src/`.

## Via spool

```toml
[dependencies]
stdlib = { git = "https://github.com/ardax-corp/coil-stdlib.git", version = "^0.1" }

[module]
roots = ["./src", "./.spool/deps/stdlib"]
```

```bash
spool add stdlib --git https://github.com/ardax-corp/coil-stdlib.git --version '^0.1'
```

If roots only list `"./.spool/deps"`, imports are prefixed: `use stdlib::ascii`.

## Path / sibling checkout

```toml
[module]
roots = ["./src", "../coil-stdlib/src"]
```

`random::Rng::from_time` seeds from [coil-time](https://github.com/ardax-corp/coil-time)
timestamps as ints. This package's `coil.toml` loads time from `.ci/coil-time`
(CI checkout). Sibling checkout is the same shape with `../coil-time`. Pass
`--allow-dload time --root .ci/coil-time/src` (CLI `--root`; the compiler does
not follow `[module] roots` or path deps for discovery) and put `libtime` on
`[ffi] search_paths`. Do not grant dload from `[ffi] allow`.

## Language repo checkout

[coil-lang](https://github.com/ardax-corp/coil-lang) does not vendor this tree.
Clone it as a sibling (`../coil-stdlib`) or under `coil-lang/.deps/coil-stdlib`.
Workspace `coil.toml` already lists those roots.

Manifest schema: [coil.toml project config](https://github.com/ardax-corp/coil-lang/blob/main/docs/references/project-config.md).
`spool` vs `coil package`: [spool README](https://github.com/ardax-corp/spool).
