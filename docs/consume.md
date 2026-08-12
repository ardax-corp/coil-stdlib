# Consume coil-stdlib

Unprefixed imports (`use ascii`, `use http::client`) need this package's **`src/`**
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

## Language repo submodule

[coil-lang](https://github.com/ardax-corp/coil-lang) vendors this package at
`stdlib/` (`git clone --recurse-submodules`). Its workspace `coil.toml` already
includes `./stdlib/src`.

Manifest schema: [coil.toml project config](https://github.com/ardax-corp/coil-lang/blob/main/docs/references/project-config.md).
`spool` vs `coil package`: [spool README](https://github.com/ardax-corp/spool).
