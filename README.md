# coil-stdlib

Userland standard library for [Coil](https://github.com/ardax-corp/coil-lang).
Compiler virtual modules cover systems primitives (`io`, `string`, `thread`, …);
this package layers `.coil` helpers on top.

Managed with [spool](https://github.com/ardax-corp/spool), same organization as
the language and package manager.

**Docs:** [docs/](docs/README.md) — consume, module catalog, IO adapters, JSON.

HTTP lives in [coil-http](https://github.com/ardax-corp/coil-http) (separate package).
CSPRNG is `crypto::random_u64` / `random_bytes` on [coil-crypto](https://github.com/ardax-corp/coil-crypto).
JSON lives in [coil-json](https://github.com/ardax-corp/coil-json) (separate package).
See [docs/codec.md](docs/codec.md).

Import **explicitly** — `use path::*` is banned (`E0124`). Prelude is auto-injected.

**API style:** prefer **method-based APIs** (`m.insert(k, v)`), not free functions.
Virtual-module host primitives (`io::read`) stay as free fns.

## Layout

```text
coil.toml
src/ascii.coil          # use ascii::…
src/cell.coil           # use cell::{Ref}
src/collections/      # map, set, list, deque, bitset, tree, vec
src/math.coil           # use math::{sin, sqrt, …} — float math in Coil
src/path.coil           # use path::{Path, …}
tests/                # coil test
docs/                 # package documentation
```

`spool` links `.spool/deps/stdlib` at this package's `src/` directory.

## Develop

Needs a Coil toolchain on `PATH` (or `COIL`). stdlib has no package
dependencies (`random::Rng::from_time` reads the builtin `clock` module):

```bash
coil test --allow-read --allow-write --allow-net
```
