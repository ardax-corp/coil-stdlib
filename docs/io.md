# IO adapters (`io::sync`, `io::file`)

Non-blocking streams are the compiler virtual module
[`io`](https://github.com/ardax-corp/coil-lang/blob/main/docs/references/io.md).
This package adds blocking loops and whole-file helpers on top.

```coil
use io::{stdout, open};
use io::sync::{write_all, read_to_end};
use io::file::{read_text, write_text};
```

Prefer `async fn` + prelude `block_on` when structuring concurrent IO.
Tutorial: [IO streams](https://github.com/ardax-corp/coil-lang/blob/main/docs/manual/tutorial/10-io-streams.md).

## `io::sync`

Blocking helpers over L0 + `await_*` (`src/io/sync.hy`), not host natives.

| Function | Notes |
|----------|-------|
| `write_all` / `read_exact` / `read_to_end` | `write_all` uses `io::write_from` |
| `accept_wait` | `accept` + `await_readable` |
| `recv_from_wait` | `recv_from` + `await_readable` |
| `print` / `println` / `eprintln` | UTF-8 stdout/stderr helpers |
| `read_line` | Until LF (strips CR); `None` on EOF with no bytes |

```coil
use io::{stdout};
use io::sync::{write_all};
use string::{format, to_bytes};

fn main() {
    write_all(stdout(), to_bytes(format("%i", 42)));
}
```

## `io::file`

| Function | Notes |
|----------|-------|
| `read_bytes` / `write_bytes` | Whole file as `Vec<byte>` |
| `read_text` / `write_text` | UTF-8 via virtual `string::{from_bytes, to_bytes}` |
