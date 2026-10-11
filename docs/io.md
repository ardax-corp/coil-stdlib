# IO adapters (`io::sync`, `io::file`)

Non-blocking streams are the compiler virtual module
[`io`](https://github.com/ardax-corp/coil-website/blob/main/src/content/docs/references/io.md).
This package adds blocking loops and whole-file helpers on top.

```coil
use io::{stdout, open};
use io::sync::{write_all, read_to_end};
use io::file::{read_text, write_text};
```

Structure concurrent IO with `task::scope` / `spawn` (IO inside a task parks it).
`block_on` is deprecated (`E0129`).
Tutorials: [IO streams](https://github.com/ardax-corp/coil-website/blob/main/src/content/docs/manual/tutorial/10-io-streams.md), [Tasks](https://github.com/ardax-corp/coil-website/blob/main/src/content/docs/manual/tutorial/12-tasks.md).

## `io::sync`

Blocking helpers over L0 + `wait_readable` / `wait_writable` (`src/io/sync.hy`), not host natives.

| Function | Notes |
|----------|-------|
| `write_all` / `read_exact` / `read_to_end` | Park on `WouldBlock`; `write_all` uses `io::write_from` |
| `accept_wait` | `accept` + `wait_readable` |
| `recv_from_wait` | `recv_from` + `wait_readable` |
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
