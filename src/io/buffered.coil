// Buffered, deadline-aware streams over L0 `io::read` / `write_from`.
//
// `Reader` and `Writer` are the one place that waits: their private fill and
// flush loops call `wait_readable` / `wait_writable`, so nothing above them
// sees `WouldBlock`. Inside a task a wait lets other tasks run. A timeout set
// with `set_timeout` applies to each wait, and costs nothing while data is
// ready.
use io::{read, write_from, wait_readable, wait_writable};
use task::{timeout, TaskError};
use string::{from_bytes as str_from_bytes, to_bytes as str_to_bytes};

// Bytes a `Reader` asks the stream for at once, and a `Writer` holds before it flushes.
fn __default_capacity() -> int {
    return 8192;
}

fn __zeroes(int n) -> Vec<byte> {
    let v: Vec<byte> = Vec::new();
    let i = 0;
    while i < n {
        v.push(0);
        i = i + 1;
    }
    return v;
}

// Waits until `s` is readable (or writable), giving up after `ms` when it is above 0.
fn __wait(Stream s, bool write, int ms) -> Result<unit, IoError> {
    if ms <= 0 {
        if write {
            return wait_writable(s);
        }
        return wait_readable(s);
    }
    let waited = timeout(
        ms,
        fn () use (s, write) {
            if write {
                return wait_writable(s);
            }
            return wait_readable(s);
        },
    );
    return match waited {
        Result::Ok(r) => r,
        Result::Err(TaskError::TimedOut) => Result::Err(IoError::TimedOut),
        Result::Err(_) => Result::Err(IoError::Other),
    };
}

/// A buffered reader over any `Stream`: lines, delimited frames, exact
/// counts, and the leftover bytes for a protocol switch.
///
/// It asks the stream for up to 8 KiB at a time, so reading a line costs one
/// host call per chunk rather than one per byte (`io::sync::read_line`).
/// Bytes it has buffered belong to the reader: once a `Reader` is in use,
/// read the stream only through it (or take them back with `take_buffered`).
///
/// # Examples
///
/// ```
/// use io::buffered::{Reader};
/// use io::file::{write_text};
/// use io::{open};
/// # use tests::assert;
/// let _ = write_text("/tmp/coil_stdlib_reader_doc.txt", "one\ntwo\n");
/// let f = match open("/tmp/coil_stdlib_reader_doc.txt", "r") {
///     Result::Ok(s) => s,
///     Result::Err(_) => panic "open",
/// };
/// let r = Reader::new(f);
/// assert!(r.read_line() == Result::Ok(Option::Some("one")));
/// assert!(r.read_line() == Result::Ok(Option::Some("two")));
/// assert!(r.read_line() == Result::Ok(Option::None));
/// ```
shared class Reader {
    pub __stream: Stream,
    // Buffered bytes are `__buf[__start..]`.
    pub __buf: Vec<byte>,
    pub __start: int,
    pub __scratch: Vec<byte>,
    pub __eof: bool,
    pub __timeout_ms: int,
}

impl Reader {
    /// A reader over `s` that asks for 8 KiB at a time.
    pub static fn new(Stream s) -> Reader {
        return Reader::with_capacity(s, __default_capacity());
    }

    /// A reader over `s` that asks for up to `n` bytes at a time (at least 1).
    pub static fn with_capacity(Stream s, int n) -> Reader {
        let buf: Vec<byte> = Vec::new();
        let size = n;
        if size < 1 {
            size = 1;
        }
        return new Reader(s, buf, 0, __zeroes(size), false, 0);
    }

    /// Gives up a wait for data after `ms` milliseconds with
    /// `Err(IoError::TimedOut)`; `0` waits for ever (the default). The timer
    /// only runs while a read actually waits.
    pub fn set_timeout(int ms) {
        self.__timeout_ms = ms;
    }

    /// The stream being read.
    pub fn stream() -> Stream {
        return self.__stream;
    }

    /// Number of bytes buffered and not yet returned.
    pub fn buffered() -> int {
        return self.__buf.len() - self.__start;
    }

    /// Reads the next line, without its `\n` or `\r\n`. A last line with no
    /// newline is returned as it is; `None` at the end of the stream.
    ///
    /// # Errors
    ///
    /// `InvalidInput` when the line is not UTF-8 (its bytes are consumed),
    /// `TimedOut` after `set_timeout`, or the stream's error.
    pub fn read_line() -> Result<Option<string>, IoError> {
        let lf: byte = "\n";
        let cr: byte = "\r";
        let line = match self.read_until(lf)? {
            Option::Some(b) => b,
            Option::None => {
                return Option::None;
            },
        };
        let n = line.len();
        if n > 0 && line[n - 1] == lf {
            n = n - 1;
            if n > 0 && line[n - 1] == cr {
                n = n - 1;
            }
        }
        let text: Vec<byte> = Vec::new();
        let i = 0;
        while i < n {
            text.push(line[i]);
            i = i + 1;
        }
        return match str_from_bytes(text) {
            Result::Ok(s) => Option::Some(s),
            Result::Err(_) => raise IoError::InvalidInput,
        };
    }

    /// Reads up to and including the next `delim` byte. Returns what is
    /// left, without `delim`, when the stream ends first; `None` when it
    /// ends with nothing left.
    ///
    /// # Errors
    ///
    /// `TimedOut` after `set_timeout`, or the stream's error.
    pub fn read_until(byte delim) -> Result<Option<Vec<byte>>, IoError> {
        let scanned = self.__start;
        while true {
            let i = scanned;
            let end = self.__buf.len();
            while i < end {
                if self.__buf[i] == delim {
                    return Option::Some(self.__take(i + 1 - self.__start));
                }
                i = i + 1;
            }
            scanned = end;
            // `__fill` may move the buffered bytes to the front.
            let before = self.__start;
            if !self.__fill()? {
                if self.buffered() == 0 {
                    return Option::None;
                }
                return Option::Some(self.__take(self.buffered()));
            }
            scanned = scanned - before + self.__start;
        }
    }

    /// Reads exactly `n` bytes.
    ///
    /// # Errors
    ///
    /// `Truncated` when the stream ends first (the bytes read so far stay
    /// buffered), `TimedOut` after `set_timeout`, or the stream's error.
    pub fn read_exact(int n) -> Result<Vec<byte>, IoError> {
        while self.buffered() < n {
            if !self.__fill()? {
                raise IoError::Truncated;
            }
        }
        return self.__take(n);
    }

    /// Returns up to `n` bytes without consuming them, waiting until `n` are
    /// buffered or the stream ends.
    ///
    /// # Errors
    ///
    /// `TimedOut` after `set_timeout`, or the stream's error.
    pub fn peek(int n) -> Result<Vec<byte>, IoError> {
        while self.buffered() < n {
            if !self.__fill()? {
                break;
            }
        }
        let out: Vec<byte> = Vec::new();
        let i = self.__start;
        let end = self.__start + n;
        if end > self.__buf.len() {
            end = self.__buf.len();
        }
        while i < end {
            out.push(self.__buf[i]);
            i = i + 1;
        }
        return out;
    }

    /// Returns the bytes that are ready: what is buffered, or else one
    /// chunk from the stream (waiting for it). `None` at the end of the stream.
    ///
    /// # Errors
    ///
    /// `TimedOut` after `set_timeout`, or the stream's error.
    pub fn read_some() -> Result<Option<Vec<byte>>, IoError> {
        if self.buffered() == 0 && !self.__fill()? {
            return Option::None;
        }
        return Option::Some(self.__take(self.buffered()));
    }

    /// Reads everything up to the end of the stream.
    ///
    /// # Errors
    ///
    /// `TimedOut` after `set_timeout`, or the stream's error.
    pub fn read_to_end() -> Result<Vec<byte>, IoError> {
        while self.__fill()? {}
        return self.__take(self.buffered());
    }

    /// Removes and returns the buffered bytes, for a protocol switch that
    /// reads the stream directly from here on (an HTTP upgrade).
    pub fn take_buffered() -> Vec<byte> {
        return self.__take(self.buffered());
    }

    // The next `n` buffered bytes, consumed.
    fn __take(int n) -> Vec<byte> {
        let out: Vec<byte> = Vec::new();
        let i = self.__start;
        let end = self.__start + n;
        while i < end {
            out.push(self.__buf[i]);
            i = i + 1;
        }
        self.__start = end;
        if self.__start == self.__buf.len() {
            let empty: Vec<byte> = Vec::new();
            self.__buf = empty;
            self.__start = 0;
        }
        return out;
    }

    // Reads one more chunk into the buffer, waiting for it. `false` at the
    // end of the stream. The only place a `Reader` waits.
    fn __fill() -> Result<bool, IoError> {
        if self.__eof {
            return false;
        }
        // Drop consumed bytes before growing.
        if self.__start > 0 {
            let rest: Vec<byte> = Vec::new();
            let i = self.__start;
            let end = self.__buf.len();
            while i < end {
                rest.push(self.__buf[i]);
                i = i + 1;
            }
            self.__buf = rest;
            self.__start = 0;
        }
        while true {
            match read(self.__stream, self.__scratch) {
                Result::Ok(Option::None) => {
                    self.__eof = true;
                    return false;
                },
                Result::Ok(Option::Some(n)) => {
                    if n > 0 {
                        let i = 0;
                        while i < n {
                            self.__buf.push(self.__scratch[i]);
                            i = i + 1;
                        }
                        return true;
                    }
                    __wait(self.__stream, false, self.__timeout_ms)?;
                },
                Result::Err(IoError::WouldBlock) => {
                    __wait(self.__stream, false, self.__timeout_ms)?;
                },
                Result::Err(e) => {
                    raise e;
                },
            }
        }
    }
}

/// A buffered writer over any `Stream`: small writes collect in memory and
/// go out in one call once 8 KiB are held, or on `flush`.
///
/// Call `flush` before closing the stream or waiting for a reply: bytes
/// still held are not sent.
///
/// # Examples
///
/// ```
/// use io::buffered::{Writer};
/// use io::file::{read_text};
/// use io::{open, close};
/// # use tests::assert;
/// let f = match open("/tmp/coil_stdlib_writer_doc.txt", "w") {
///     Result::Ok(s) => s,
///     Result::Err(_) => panic "open",
/// };
/// let w = Writer::new(f);
/// let _ = w.write_str("hello ");
/// let _ = w.write_str("world");
/// let _ = w.flush();
/// let _ = close(f);
/// assert!(read_text("/tmp/coil_stdlib_writer_doc.txt") == Result::Ok("hello world"));
/// ```
shared class Writer {
    pub __stream: Stream,
    pub __buf: Vec<byte>,
    pub __capacity: int,
    pub __timeout_ms: int,
}

impl Writer {
    /// A writer over `s` that holds up to 8 KiB before it writes.
    pub static fn new(Stream s) -> Writer {
        return Writer::with_capacity(s, __default_capacity());
    }

    /// A writer over `s` that holds up to `n` bytes before it writes.
    pub static fn with_capacity(Stream s, int n) -> Writer {
        let buf: Vec<byte> = Vec::new();
        return new Writer(s, buf, n, 0);
    }

    /// Gives up a wait for the stream to take more bytes after `ms`
    /// milliseconds with `Err(IoError::TimedOut)`; `0` waits for ever.
    pub fn set_timeout(int ms) {
        self.__timeout_ms = ms;
    }

    /// The stream being written.
    pub fn stream() -> Stream {
        return self.__stream;
    }

    /// Number of bytes held and not yet written.
    pub fn buffered() -> int {
        return self.__buf.len();
    }

    /// Adds `bytes`, writing out what is held once it reaches the capacity.
    ///
    /// # Errors
    ///
    /// `TimedOut` after `set_timeout`, or the stream's error.
    pub fn write(Vec<byte> bytes) -> Result<unit, IoError> {
        for b in bytes {
            self.__buf.push(b);
        }
        if self.__buf.len() >= self.__capacity {
            self.flush()?;
        }
        return;
    }

    /// Adds the UTF-8 bytes of `s`, like `write`.
    ///
    /// # Errors
    ///
    /// As `write`.
    pub fn write_str(string s) -> Result<unit, IoError> {
        return self.write(str_to_bytes(s));
    }

    /// Writes out everything held, waiting while the stream is not ready.
    ///
    /// # Errors
    ///
    /// `TimedOut` after `set_timeout`, or the stream's error. The bytes not
    /// yet written stay held.
    pub fn flush() -> Result<unit, IoError> {
        let offset = 0;
        let total = self.__buf.len();
        while offset < total {
            match write_from(self.__stream, self.__buf, offset) {
                Result::Ok(n) => {
                    if n == 0 {
                        self.__keep_from(offset);
                        __wait(self.__stream, true, self.__timeout_ms)?;
                        offset = 0;
                        total = self.__buf.len();
                    }
                    offset = offset + n;
                },
                Result::Err(IoError::WouldBlock) => {
                    self.__keep_from(offset);
                    __wait(self.__stream, true, self.__timeout_ms)?;
                    offset = 0;
                    total = self.__buf.len();
                },
                Result::Err(e) => {
                    self.__keep_from(offset);
                    raise e;
                },
            }
        }
        let empty: Vec<byte> = Vec::new();
        self.__buf = empty;
        return;
    }

    // Keeps only the held bytes from `offset` on.
    fn __keep_from(int offset) {
        if offset == 0 {
            return;
        }
        let rest: Vec<byte> = Vec::new();
        let i = offset;
        let end = self.__buf.len();
        while i < end {
            rest.push(self.__buf[i]);
            i = i + 1;
        }
        self.__buf = rest;
    }
}
