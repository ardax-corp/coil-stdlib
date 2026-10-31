// Blocking IO adapters over L0 + `wait_readable` / `wait_writable` (userland; not host natives).
use io::read;
use io::write_from;
use io::wait_readable;
use io::wait_writable;
use io::stdout;
use io::stderr;
use io::net::tcp::accept;
use io::net::udp::recv_from;
use io::net::udp::send_to;
use io::fs::copy as fs_copy;
use string::{from_bytes as str_from_bytes, to_bytes as str_to_bytes};

/// Writes all of `buf` to `s`, waiting whenever the stream is not ready.
///
/// `io::write` may write only part of a buffer; this keeps going until every
/// byte is out, then returns `Ok(0)`. Inside a task, the waits let other
/// tasks run.
/// # Examples
///
/// ```
/// use io::sync::{write_all};
/// # use tests::assert;
/// use io::{stdout};
/// use string::{to_bytes};
/// let written = write_all(stdout(), to_bytes("hi\n"));
/// assert!(written.is_ok());
/// ```
fn write_all(Stream s, Vec<byte> buf) -> Result<int, IoError> {
    let offset = 0;
    let total = buf.len();
    while offset < total {
        match write_from(s, buf, offset) {
            Result::Ok(n) => {
                if n == 0 {
                    wait_writable(s)?;
                }
                if n != 0 {
                    offset = offset + n;
                }
            },
            Result::Err(IoError::WouldBlock) => {
                wait_writable(s)?;
            },
            Result::Err(e) => {
                raise e;
            },
        }
    }
    return 0;
}

/// Fills all of `buf` from `s`, waiting whenever no data is ready.
///
/// Returns `Some(n)`: `n` is `buf.len()` once `buf` is full, or fewer when the
/// stream ends part way. Returns `None` when the stream ends before any byte.
fn read_exact(Stream s, Vec<byte> buf) -> Result<Option<int>, IoError> {
    let need = buf.len();
    let filled = 0;
    while filled < need {
        // Scratch length must equal remaining: L0 `read` fills the whole buffer.
        let remaining = need - filled;
        let scratch: Vec<byte> = Vec::new();
        let i = 0;
        while i < remaining {
            scratch.push(0);
            i = i + 1;
        }
        match read(s, scratch) {
            Result::Ok(Option::None) => {
                if filled == 0 {
                    return Option::None;
                }
                return Option::Some(filled);
            },
            Result::Ok(Option::Some(n)) => {
                if n == 0 {
                    wait_readable(s)?;
                }
                if n != 0 {
                    let j = 0;
                    while j < n {
                        buf[filled + j] = scratch[j];
                        j = j + 1;
                    }
                    filled = filled + n;
                }
            },
            Result::Err(IoError::WouldBlock) => {
                wait_readable(s)?;
            },
            Result::Err(e) => {
                raise e;
            },
        }
    }
    return Option::Some(filled);
}

/// Reads from `s` until it ends and returns everything read.
fn read_to_end(Stream s) -> Result<Vec<byte>, IoError> {
    let acc: Vec<byte> = Vec::new();
    let chunk_size = 4096;
    let scratch: Vec<byte> = Vec::new();
    let i = 0;
    while i < chunk_size {
        scratch.push(0);
        i = i + 1;
    }
    let done = false;
    while !done {
        match read(s, scratch) {
            Result::Ok(Option::None) => {
                done = true;
            },
            Result::Ok(Option::Some(n)) => {
                if n == 0 {
                    wait_readable(s)?;
                }
                if n != 0 {
                    let j = 0;
                    while j < n {
                        acc.push(scratch[j]);
                        j = j + 1;
                    }
                }
            },
            Result::Err(IoError::WouldBlock) => {
                wait_readable(s)?;
            },
            Result::Err(e) => {
                raise e;
            },
        }
    }
    return acc;
}

/// Waits for the next connection on a TCP `listener` and returns its stream.
fn accept_wait(Stream listener) -> Result<Stream, IoError> {
    let done = false;
    let out = listener;
    while !done {
        match accept(listener) {
            Result::Ok(s) => {
                out = s;
                done = true;
            },
            Result::Err(IoError::WouldBlock) => {
                wait_readable(listener)?;
            },
            Result::Err(e) => {
                raise e;
            },
        }
    }
    return out;
}

/// Waits for a UDP datagram, reads it into `buf`, and returns `(bytes, sender host, sender port)`.
fn recv_from_wait(Stream s, Vec<byte> buf) -> Result<(int, string, int), IoError> {
    let done = false;
    let out_n = 0;
    let out_host = "";
    let out_port = 0;
    while !done {
        match recv_from(s, buf) {
            Result::Ok(t) => {
                out_n = t[0];
                out_host = t[1];
                out_port = t[2];
                done = true;
            },
            Result::Err(IoError::WouldBlock) => {
                wait_readable(s)?;
            },
            Result::Err(e) => {
                raise e;
            },
        }
    }
    return (out_n, out_host, out_port);
}

/// Sends `buf` as one UDP datagram to `host`:`port`, waiting while the socket is not ready.
fn send_to_wait(Stream s, Vec<byte> buf, string host, int port) -> Result<int, IoError> {
    let done = false;
    let out_n = 0;
    while !done {
        match send_to(s, buf, host, port) {
            Result::Ok(n) => {
                out_n = n;
                done = true;
            },
            Result::Err(IoError::WouldBlock) => {
                wait_writable(s)?;
            },
            Result::Err(e) => {
                raise e;
            },
        }
    }
    return out_n;
}

/// Copies the file `src` to `dst`. Note the argument order: destination first. See `io::fs::copy`.
fn copy(string dst, string src) -> Result<int, IoError> {
    fs_copy(src, dst)?;
    return 0;
}

fn newline_bytes() -> Vec<byte> {
    let nl: Vec<byte> = Vec::new();
    nl.push("\n");
    return nl;
}

/// Writes `s` to standard output, without a newline.
///
/// # Errors
///
/// Returns `Err` when standard output cannot be written (for example, a closed pipe).
/// # Examples
///
/// ```
/// use io::sync::{print};
/// # use tests::assert;
/// print("no newline")?;
/// ```
fn print(string s) -> Result<int, IoError> {
    return write_all(stdout(), str_to_bytes(s))?;
}

/// Writes `s` and a newline to standard output.
///
/// The usual way to print. It returns a `Result` like all IO, so write
/// `println(…)?;` in a function that can return the error (`main` can).
/// Build the text with `string::format`.
///
/// # Errors
///
/// Returns `Err` when standard output cannot be written (for example, a closed pipe).
///
/// # Examples
///
/// ```
/// use io::sync::{println};
/// use string::{format};
///
/// fn main() {
///     println("Hello, Coil!")?;
///     println(format("%i + %i = %i", 2, 2, 2 + 2))?;
/// }
/// ```
fn println(string s) -> Result<int, IoError> {
    write_all(stdout(), str_to_bytes(s))?;
    return write_all(stdout(), newline_bytes())?;
}

/// Writes `s` and a newline to standard error. Use it for diagnostics, so they stay out of the program's output.
/// # Examples
///
/// ```
/// use io::sync::{eprintln};
/// # use tests::assert;
/// eprintln("warning: no config file, using defaults")?;
/// ```
fn eprintln(string s) -> Result<int, IoError> {
    write_all(stderr(), str_to_bytes(s))?;
    return write_all(stderr(), newline_bytes())?;
}

// A read line as text; bytes that are not UTF-8 are `InvalidInput`.
fn line_text(Vec<byte> b) -> Result<string, IoError> {
    return match str_from_bytes(b) {
        Result::Ok(s) => s,
        Result::Err(_) => raise IoError::InvalidInput,
    };
}

/// Reads one line from `s`, without its line ending (LF or CRLF).
///
/// Returns `None` at the end of the stream. A last line without a newline is
/// still returned.
///
/// # Examples
///
/// ```no_run
/// use io::{stdin};
/// use io::sync::{read_line, println};
///
/// fn main() {
///     while let Option::Some(line) = read_line(stdin())? {
///         println(line)?;
///     }
/// }
/// ```
fn read_line(Stream s) -> Result<Option<string>, IoError> {
    let acc: Vec<byte> = Vec::new();
    // One-byte reads: a larger scratch would consume past LF without pushback.
    let scratch: Vec<byte> = Vec::new();
    scratch.push(0);
    let done = false;
    let saw = false;
    let lf: byte = "\n";
    let cr: byte = "\r";
    while !done {
        match read(s, scratch) {
            Result::Ok(Option::None) => {
                done = true;
            },
            Result::Ok(Option::Some(n)) => {
                if n == 0 {
                    wait_readable(s)?;
                }
                if n != 0 {
                    saw = true;
                    let c = scratch[0];
                    if c == lf {
                        done = true;
                    }
                    if c != lf {
                        acc.push(c);
                    }
                }
            },
            Result::Err(IoError::WouldBlock) => {
                wait_readable(s)?;
            },
            Result::Err(e) => {
                raise e;
            },
        }
    }
    if !saw {
        return Option::None;
    }
    if acc.len() > 0 {
        if acc[acc.len() - 1] == cr {
            let trimmed: Vec<byte> = Vec::new();
            let i = 0;
            while i + 1 < acc.len() {
                trimmed.push(acc[i]);
                i = i + 1;
            }
            return Option::Some(line_text(trimmed)?);
        }
    }
    return Option::Some(line_text(acc)?);
}
