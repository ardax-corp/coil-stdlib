# Consume coil-stdlib

Unprefixed imports (`use ascii`, `use collections::map::{HashMap}`) need this package's **`src/`**
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

## Language repo checkout

[coil-lang](https://github.com/ardax-corp/coil-lang) does not vendor this tree.
Clone it as a sibling (`../coil-stdlib`) or under `coil-lang/.deps/coil-stdlib`.
Workspace `coil.toml` already lists those roots.

Manifest schema: [coil.toml project config](https://github.com/ardax-corp/coil-lang/blob/main/docs/references/project-config.md).
`spool` vs `coil package`: [spool README](https://github.com/ardax-corp/spool).
