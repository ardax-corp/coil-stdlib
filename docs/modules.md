# Module catalog

`use path::*` is banned (`E0124`). List names explicitly.

IEEE float math is auto-imported from virtual `prelude::math` in the
compiler — not this package: `sin`/`cos`/`tan`/`sqrt`/`floor`/`ceil`/
`exp`/`ln`, `atan`/`atan2`/`asin`/`acos`, `log10`/`log2`/`cbrt`, and
`sinh`/`cosh`/`tanh`. `num` does not re-export those. Float power and
remainder are the `**` and `%` operators (`num` has no `pow`; overflow-aware
int powers are `arith`'s `checked_pow` and friends). Named float constants `PI`,
`E`, and `TAU` live on `num` as compile-time `const`s (not HostInvoke).

HTTP lives in the separate [coil-http](https://github.com/ardax-corp/coil-http)
package (`use http::client::{Client};`).
CSPRNG is `crypto::random_u64` / `random_bytes` on
[coil-crypto](https://github.com/ardax-corp/coil-crypto).

JSON lives in the separate [coil-json](https://github.com/ardax-corp/coil-json)
package (`use json::{Json, JsonValue, JsonError};`). There is no in-tree
`codec::json`. This package does not re-export it. See [JSON](codec.md).

| Module | Import | Role |
|--------|--------|------|
| `arith` | `use arith::{INT_MAX, INT_MIN, Checked, Wrapping, …};` | Explicit int overflow for add/sub/mul/neg/pow: `checked_*` (`Option`), `wrapping_*` (mod 2^64), `saturating_*`, `overflowing_*` (`(int, bool)`); plain `+ - *` panic on overflow. `checked_shl`/`shr`, `wrapping_shl`/`shr` (count `& 63`) and `overflowing_shl`/`shr` take a shift count outside `0..=63`, which `<<` / `>>` trap on |
| `cell` | `use cell::{Ref};` | `Ref<T>` shared mutable cell (`get` / `set` / `replace` / `update`); use it where a `use (x)` capture snapshot needs to see writes |
| `ascii` | `use ascii::{is_digit, is_alnum, …};` | ASCII classify / digit / case helpers |
| `conv` | `use conv::{parse_int, int_to_hex, …};` | `int_to_dec` / `parse_int` / `parse_float` / radix parse |
| `bytes` | `use bytes::{slice, concat, to_hex, …};` | `Vec<byte>` helpers; `Bytes` wrapper; hex encode/decode |
| `text` | `use text::{Searchable, Text, rfind, join};` | String helpers via UTF-8 bytes (virtual `string` owns `format` / `to_bytes`). `Text` gives `string` plain-value methods: `s.trim()` / `trim_start` / `trim_end` / `to_lower` / `to_upper` / `lines` / `repeat(n)` / `pad_left(width, fill)` / `pad_right` (an empty `fill` returns `s`), plus `s.slice(a, b)` / `split_at(i)`, which return `Err("utf8")` for an offset inside a character. `Searchable` gives `string` (and any `Show` type with an empty `impl`) pattern methods: `"foobar".contains(p)`, `starts_with` / `ends_with` / `find` / `find_all` / `split` / `split_once` / `replace_first` / `replace_all`, where `p` is a `string` or any `Pattern` (coil-regex's `Regex`) |
| `encoding` | `use encoding::{encode, decode};` | Standard Base64 encode/decode |
| `fmt` | `use fmt::{Buf, pad_left, …};` | Incremental string builder (`Buf`) and padding helpers |
| `collections` | `use collections::{sort, sort_by, reverse, …};` | Stable mergesort / `sort_by` (`T -> K` with `K: Ord`) / `reverse` / `collect_ints`; strings sort by UTF-8 bytes |
| `collections::vec` | `use collections::vec::{map, filter, chunks, windows, partition, …};` | `Vec<T>` helpers: `map` / `filter` / `chunks` / `windows` / `partition` / `first` / `contains` / … |
| `collections::map` | `use collections::map::{HashMap};` | Chaining hash map (`Eq`+`Hash`); `get(k, fallback)` |
| `collections::set` | `use collections::set::{HashSet};` | Unique-value set backed by `HashMap<T, bool>` |
| `collections::list` | `use collections::list::{List};` | Mutable deque (singly-linked); `peek_*` / `pop_*` → `Option` |
| `collections::deque` | `use collections::deque::{VecDeque};` | Ring-buffer deque over growable `Vec`; O(1) push/pop at both ends |
| `collections::bitset` | `use collections::bitset::{BitSet};` | Dense bit set of non-negative `int` indices; 63 bits per `int` word |
| `collections::tree` | `use collections::tree::{TreeMap};` | Mutable BST map over `Ord`+`Eq`; remove / min / max / iter |
| `num` | `use num::{PI, E, TAU, abs, min, signum, gcd, …};` | Float constants `PI`/`E`/`TAU`; helpers: `abs`, `min`/`max`/`clamp` over `Ord`, `round`, `signum`, `gcd`/`lcm`, `trunc`/`fract`, NaN/inf checks, euclidean div/rem, `hypot` |
| `random` | `use random::{Rng};` | Seeded `Rng` PRNG (`from_time` mixes [coil-time](https://github.com/ardax-corp/coil-time) timestamps as ints) |
| `path` | `use path::{Path};` | `Path` value: join / normalize / components / FS + file I/O |
| `io::sync` | `use io::sync::{write_all, copy, …};` | Blocking adapters — [IO adapters](io.md) |
| `io::file` | `use io::file::{read_text, append_bytes, …};` | Whole-file read/write/append — [IO adapters](io.md) |

## Notes

- Prefer **byte offsets** for `s.slice(a, b)` / `rfind` / `Span` offsets (mid-codepoint slices error on decode).
- Byte constants use single-byte string literals (`"/"`, `"\n"`) under `byte` /
  `Vec<byte>` expected types; whole string literals coerce to `Vec<byte>` /
  `[byte; N]` too (`to_bytes(s)` for a string value).
- `num` is named so a project `math.hy` does not shadow it.
- Collections that are type-tied should be **methods** (`m.insert(k, v)`).
  Cross-module user classes are still limited in the language
  ([COI-12](https://linear.app/ardax/issue/COI-12)).
- Generic `HashMap::get` returns a fallback value (not `Option<V>`) due to a
  compiler limitation on generic class methods returning `Option`.
- `collections::vec::map` / `filter` / `partition` accept open-`T` lambdas; `fold` is
  currently available for `Vec<int>` only.
- `chunks` is the only name (no `chunk` alias). `windows` is overlapping
  exact-size slices; empty when `size <= 0` or `size > len`.
- `partition` returns `Partitioned<T>` (`matched()` / `rest()`), a named pair
  rather than `Vec<Vec<T>>`, so buckets are not positional `[0]`/`[1]`.
- `sort_by<T, K: Ord>` uses the same `T -> K` / `K: Ord` story as `map` + `sort`.
- `BitSet::with_capacity` / `capacity` are in **bits**. Storage is `Vec<int>`
  with 63 usable bits per word (Coil `int` is signed 64-bit; sign bit unused).
- Lambda, `defer` and task `use (x)` captures copy the local, so assigning to
  it inside the closure is not seen outside. Capture a `cell::Ref` instead and
  call `set` / `update` on it.

What the **compiler** does *not* provide as builtins:
[not-builtins](https://github.com/ardax-corp/coil-website/blob/main/src/content/docs/references/not-builtins.md).
