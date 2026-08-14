# Module catalog

`use path::*` is banned (`E0124`). List names explicitly.

IEEE float math (`sin`, `cos`, `sqrt`, `floor`, `ceil`, `exp`, `ln`) is
auto-imported from virtual `prelude::math` in the compiler — not this package.
`pow` is userland here (`num`).

HTTP lives in the separate [coil-http](https://github.com/ardax-corp/coil-http)
package (`use http::client::{Client};`).

| Module | Import | Role |
|--------|--------|------|
| `ascii` | `use ascii::{is_digit, is_alnum, …};` | ASCII classify / digit / case helpers |
| `conv` | `use conv::{parse_int, int_to_hex, …};` | `int_to_dec` / `parse_int` / `parse_float` / radix parse |
| `bytes` | `use bytes::{slice, concat, to_hex, …};` | `[byte]` helpers; `Bytes` wrapper; hex encode/decode |
| `text` | `use text::{trim, split, rfind, …};` | String helpers via UTF-8 bytes (virtual `string` owns `format` / `to_bytes`) |
| `encoding` | `use encoding::{encode, decode};` | Standard Base64 encode/decode |
| `fmt` | `use fmt::{Buf, pad_left, …};` | Incremental string builder (`Buf`) and padding helpers |
| `collections` | `use collections::{sort, reverse, …};` | Stable mergesort / `reverse` / `collect_ints` |
| `collections::vec` | `use collections::vec::{map, filter, …};` | `Vec<T>` helpers: `map` / `filter` / `first` / `contains` / `chunks` / … |
| `collections::map` | `use collections::map::{HashMap};` | Chaining hash map (`Eq`+`Hash`); `get(k, fallback)` |
| `collections::set` | `use collections::set::{HashSet};` | Unique-value set backed by `HashMap<T, bool>` |
| `collections::list` | `use collections::list::{List};` | Mutable deque (singly-linked); `peek_*` / `pop_*` → `Option` |
| `collections::tree` | `use collections::tree::{TreeMap};` | Mutable BST map over `Ord`+`Eq`; remove / min / max / iter |
| `num` | `use num::{abs, min, signum, gcd, …};` | Numeric helpers: `abs`, `min`/`max`/`clamp` over `Ord`, `round`, `pow`, `signum`, `gcd`/`lcm`, `trunc`/`fract`, NaN/inf checks, euclidean div/rem, `hypot` |
| `random` | `use random::{Rng, crypto_u64, …};` | Seeded `Rng` PRNG + `crypto_u64` / `crypto_bytes` wrappers |
| `path` | `use path::{Path};` | `Path` value: join / normalize / components / FS + file I/O |
| `io::sync` | `use io::sync::{write_all, copy, …};` | Blocking adapters — [IO adapters](io.md) |
| `io::file` | `use io::file::{read_text, append_bytes, …};` | Whole-file read/write/append — [IO adapters](io.md) |

## Notes

- Prefer **byte offsets** for `text::slice` / `find` (mid-codepoint slices error on decode).
- Byte constants use single-byte string literals (`"/"`, `"\n"`) under `byte` /
  `[byte]` expected types; whole strings coerce to `[byte]` / `[byte; N]` too.
- `num` is named so a project `math.hy` does not shadow it.
- Collections that are type-tied should be **methods** (`m.insert(k, v)`).
  Cross-module user classes are still limited in the language
  ([COI-12](https://linear.app/ardax/issue/COI-12)).
- Generic `HashMap::get` returns a fallback value (not `Option<V>`) due to a
  compiler limitation on generic class methods returning `Option`.
- `collections::vec::map` / `filter` accept open-`T` lambdas; `fold` is
  currently available for `Vec<int>` only.

What the **compiler** does *not* provide as builtins:
[coil-lang not-builtins](https://github.com/ardax-corp/coil-lang/blob/main/docs/references/not-builtins.md).
