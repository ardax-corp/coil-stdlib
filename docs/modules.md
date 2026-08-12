# Module catalog

`use path::*` is banned (`E0124`). List names explicitly.

IEEE float math (`sin`, `cos`, `sqrt`, `floor`, `ceil`, `exp`, `ln`) is
auto-imported from virtual `prelude::math` in the compiler — not this package.
`pow` is userland here (`num`).

| Module | Import | Role |
|--------|--------|------|
| `ascii` | `use ascii::{is_digit, …};` | ASCII classify / decimal digit helpers |
| `conv` | `use conv::{parse_int, …};` | `int_to_dec` / `parse_int` / `parse_float` |
| `bytes` | `use bytes::{slice, concat, …};` | `[byte]` slice / concat / find / replace / pad / eq |
| `text` | `use text::{trim, split, …};` | String helpers via UTF-8 bytes (virtual `string` owns `format` / `to_bytes`) |
| `collections` | `use collections::{sort, …};` | Stable mergesort / `reverse` / `collect_ints` |
| `collections::map` | `use collections::map::{HashMap, HashSet};` | Chaining map/set (`Eq`+`Hash`) |
| `collections::list` | `use collections::list::{List};` | Mutable singly-linked list |
| `collections::tree` | `use collections::tree::{TreeMap};` | Mutable BST map over `Ord`+`Eq` |
| `num` | `use num::{abs, min, …};` | Numeric conveniences (`abs` overloads; `min`/`max`/`clamp` over `Ord`; `round`; `pow`) |
| `random` | `use random::{u64, range, …};` | CSPRNG wrappers over virtual `crypto` |
| `path` | `use path::{join, dirname, …};` | `join` / `dirname` / `basename` / `extension` |
| `io::sync` | `use io::sync::{write_all, …};` | Blocking adapters — [IO adapters](io.md) |
| `io::file` | `use io::file::{read_text, …};` | Whole-file read/write — [IO adapters](io.md) |
| `http` | `use http::client::{get, …};` | HTTP/1.1 client — [HTTP](http.md) |

## Notes

- Prefer **byte offsets** for `text::slice` / `find` (mid-codepoint slices error on decode).
- Byte constants use single-byte string literals (`"/"`, `"\n"`) under `byte` /
  `[byte]` expected types; whole strings coerce to `[byte]` / `[byte; N]` too.
- `num` is named so a project `math.hy` does not shadow it.
- Collections that are type-tied should be **methods** (`m.insert(k, v)`).
  Cross-module user classes are still limited in the language
  ([COI-12](https://linear.app/ardax/issue/COI-12)).

What the **compiler** does *not* provide as builtins:
[coil-lang not-builtins](https://github.com/ardax-corp/coil-lang/blob/main/docs/references/not-builtins.md).
