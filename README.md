# coil-stdlib

Userland standard library for [Coil](https://github.com/ardax-corp/coil-lang).
Compiler virtual modules cover systems primitives (`io`, `string`, `thread`, …);
this package layers `.hy` helpers on top.

Managed with [spool](https://github.com/ardax-corp/spool), same organization as
the language and package manager.

Import **explicitly** — `use path::*` is banned (`E0124`). Prelude is auto-injected.

**API style:** prefer **method-based APIs** — operations on a type are `impl`
methods (`m.insert(k, v)`), not module-level free functions. Virtual-module host
primitives (`io::read`) stay as free fns.

| Module | Import | Role |
|--------|--------|------|
| `ascii` | `use ascii::{is_digit, …};` | ASCII classify / decimal digit helpers |
| `conv` | `use conv::{parse_int, …};` | `int_to_dec` / `parse_int` / `parse_float` |
| `bytes` | `use bytes::{slice, concat, …};` | `[byte]` slice / concat / find / replace / pad / eq |
| `text` | `use text::{trim, split, …};` | String helpers via UTF-8 bytes |
| `collections` | `use collections::{sort, …};` | Stable mergesort / `reverse` / `collect_ints` |
| `collections::map` | `use collections::map::{HashMap, HashSet};` | Chaining map/set (`Eq`+`Hash`) |
| `collections::list` | `use collections::list::{List};` | Mutable singly-linked list |
| `collections::tree` | `use collections::tree::{TreeMap};` | Mutable BST map over `Ord`+`Eq` |
| `num` | `use num::{abs, min, …};` | Numeric conveniences |
| `random` | `use random::{u64, range, …};` | CSPRNG wrappers over virtual `crypto` |
| `path` | `use path::{join, dirname, …};` | Path join / dirname / basename / extension |
| `io::sync` | `use io::sync::{write_all, …};` | Blocking adapters + `print` / `println` |
| `io::file` | `use io::file::{read_text, …};` | Whole-file read/write |
| `http` | `use http::client::{get, …};` | HTTP/1.1 client |

## Layout

```text
coil.toml
src/ascii.hy          # use ascii::…
src/http/client.hy    # use http::client::…
tests/                # coil test
```

`spool` links `.spool/deps/stdlib` at this package's `src/` directory.

## Consume

Unprefixed imports (`use ascii`, `use http::client`) need the **package directory**
as a module root, not the parent `.spool/deps` folder:

```toml
[dependencies]
stdlib = { git = "https://github.com/ardax-corp/coil-stdlib.git", version = "^0.1" }

[module]
roots = ["./src", "./.spool/deps/stdlib"]
```

```bash
spool add stdlib --git https://github.com/ardax-corp/coil-stdlib.git --version '^0.1'
```

Path checkout (language repo git submodule, or a sibling clone):

```toml
[module]
roots = ["./src", "../coil-stdlib/src"]
```

## Develop

Needs a Coil toolchain on `PATH` (or `COIL`):

```bash
coil test
```

## Notes

- Prefer **byte offsets** for `text::slice` / `find` (mid-codepoint slices error on decode).
- Byte constants use single-byte string literals (`"/"`, `"\n"`) under `byte` /
  `[byte]` expected types.
- IEEE float math (`sin`, `cos`, `sqrt`, …) is auto-imported from virtual
  `prelude::math`. `pow` is userland in `num`.
