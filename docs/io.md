# IO adapters (`io::buffered`, `io::sync`, `io::file`, `net`)

Non-blocking streams are the compiler virtual module
[`io`](https://github.com/ardax-corp/coil-website/blob/main/src/content/docs/references/io.md).
This package adds blocking loops and whole-file helpers on top.

```coil
use io::{stdout, open};
use io::sync::{write_all, read_to_end};
use io::file::{read_text, write_text};
```

Structure concurrent IO with `task::scope` / `spawn` (IO inside a task parks it).
For a one-off generator, `task::block_on` resumes it to completion.
Tutorials: [IO streams](https://github.com/ardax-corp/coil-website/blob/main/src/content/docs/manual/tutorial/10-io-streams.md), [Tasks](https://github.com/ardax-corp/coil-website/blob/main/src/content/docs/manual/tutorial/12-tasks.md).

## `io::buffered`

`Reader` and `Writer` over any `Stream` (TCP, files, stdio, attached TLS streams). They are the one place that waits: only their fill and flush loops call `wait_readable` / `wait_writable`, so nothing above them sees `WouldBlock`, and inside a task a wait lets other tasks run.

| Method | Notes |
|--------|-------|
| `Reader::new(s)` / `with_capacity(s, n)` | Asks the stream for up to 8 KiB (or `n` bytes) at a time |
| `read_line()` | `Option<string>` without `\n` / `\r\n`; `None` at the end |
| `read_until(delim)` | Bytes up to and including `delim` |
| `read_exact(n)` | `Err(IoError::Truncated)` when the stream ends first |
| `peek(n)` / `read_some()` / `read_to_end()` | Look ahead, take what is ready, read everything |
| `take_buffered()` | Hands the buffered bytes to a protocol switch (HTTP upgrade) |
| `Writer::new(s)` / `write(bytes)` / `write_str(s)` / `flush()` | Holds up to 8 KiB, then writes; call `flush` before closing or waiting for a reply |
| `set_timeout(ms)` | On both: a wait longer than `ms` gives `Err(IoError::TimedOut)`. The timer runs only while a call actually waits |

```coil
use io::buffered::{Reader, Writer};

fn echo(Stream conn) -> Result<unit, IoError> {
    let r = Reader::new(conn);
    let w = Writer::new(conn);
    r.set_timeout(30000);
    while let Option::Some(line) = r.read_line()? {
        w.write_str(line + "\n")?;
        w.flush()?;
    }
    return ();
}
```

## `net`

`net::serve(listener, max, handler)` accepts connections and runs `handler(conn)` on each in its own task, at most `max` at once; each connection is closed when its handler returns. It returns `Ok(count)` once the listener is closed, or the `accept` error. A panicking handler fails the whole call, as a panic fails its scope.

```coil
use net::{serve};
use io::net::tcp::{listen};

fn main() {
    let l = match listen("127.0.0.1", 8080) {
        Result::Ok(s) => s,
        Result::Err(_) => panic "listen",
    };
    let _ = serve(l, 64, fn (Stream conn) {
        let _ = echo(conn);
    });
}
```

## `io::sync`

Blocking helpers over L0 + `wait_readable` / `wait_writable` (`src/io/sync.hy`), not host natives.

| Function | Notes |
|----------|-------|
| `write_all` / `read_exact` / `read_to_end` | Park on `WouldBlock`; `write_all` uses `io::write_from` |
| `accept_wait` | `accept` + `wait_readable` |
| `recv_from_wait` | `recv_from` + `wait_readable` |
| `print` / `println` / `eprintln` | UTF-8 stdout/stderr helpers |
| `read_line` | Until LF (strips CR); `None` on EOF with no bytes. One `read` per byte: use `io::buffered::Reader` in a loop |

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
