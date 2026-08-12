# coil-stdlib

Userland standard library for [Coil](https://github.com/ardax-corp/coil-lang).
Compiler virtual modules cover systems primitives (`io`, `string`, `thread`, …);
this package layers `.hy` helpers on top.

Managed with [spool](https://github.com/ardax-corp/spool), same organization as
the language and package manager.

**Docs:** [docs/](docs/README.md) — consume, module catalog, HTTP client, IO adapters.

Import **explicitly** — `use path::*` is banned (`E0124`). Prelude is auto-injected.

**API style:** prefer **method-based APIs** (`m.insert(k, v)`), not free functions.
Virtual-module host primitives (`io::read`) stay as free fns.

## Layout

```text
coil.toml
src/ascii.hy          # use ascii::…
src/http/client.hy    # use http::client::…
tests/                # coil test
docs/                 # package documentation
```

`spool` links `.spool/deps/stdlib` at this package's `src/` directory.

## Develop

Needs a Coil toolchain on `PATH` (or `COIL`):

```bash
coil test
```
