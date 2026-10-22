// Whole-file helpers over `io::open` + `io::sync` (userland).
use io::open;
use io::close;
use io::IoError;
use io::sync::read_to_end;
use io::sync::write_all;
use string::{to_bytes, from_bytes};

/// Reads the whole file at `path`.
///
/// Needs `--allow-read`.
///
/// # Errors
///
/// `IoError::NotFound` when the file does not exist, `PermissionDenied` when it cannot be opened.
fn read_bytes(string path) -> Result<Vec<byte>, IoError> {
    let s = open(path, "r")?;
    let buf = match read_to_end(s) {
        Result::Ok(b) => b,
        Result::Err(e) => {
            match close(s) {
                Result::Ok(_) => 0,
                Result::Err(_) => 0,
            }
            raise e;
        },
    };
    close(s)?;
    return buf;
}

/// Replaces the contents of the file at `path` with `buf`, creating it if needed, and returns the number of bytes written. Needs `--allow-write`.
fn write_bytes(string path, Vec<byte> buf) -> Result<int, IoError> {
    let s = open(path, "w")?;
    match write_all(s, buf) {
        Result::Ok(_) => 0,
        Result::Err(e) => {
            match close(s) {
                Result::Ok(_) => 0,
                Result::Err(_) => 0,
            }
            raise e;
        },
    }
    close(s)?;
    return 0;
}

/// Reads the whole file at `path` as UTF-8 text.
///
/// Needs `--allow-read`.
///
/// # Errors
///
/// `IoError::NotFound` when the file does not exist and `IoError::InvalidInput`
/// when it is not valid UTF-8.
///
/// # Examples
///
/// ```no_run
/// use io::file::{read_text};
/// use io::sync::{println};
///
/// fn main() {
///     let config = read_text("config.toml")?;
///     println(config)?;
/// }
/// ```
fn read_text(string path) -> Result<string, IoError> {
    let b = read_bytes(path)?;
    return match from_bytes(b) {
        Result::Ok(s) => s,
        Result::Err(e) => raise e,
    };
}

/// Replaces the contents of the file at `path` with `text`, creating it if needed, and returns the number of bytes written.
///
/// Needs `--allow-write`.
///
/// # Examples
///
/// ```no_run
/// use io::file::{write_text, read_text};
///
/// fn main() {
///     write_text("greeting.txt", "hello\n")?;
///     let back = read_text("greeting.txt")?;
/// }
/// ```
fn write_text(string path, string text) -> Result<int, IoError> {
    let b = to_bytes(text);
    return write_bytes(path, b)?;
}

/// Appends `buf` to the file at `path`, creating it if needed. Needs `--allow-write`.
fn append_bytes(string path, Vec<byte> buf) -> Result<int, IoError> {
    let s = open(path, "a")?;
    match write_all(s, buf) {
        Result::Ok(_) => 0,
        Result::Err(e) => {
            match close(s) {
                Result::Ok(_) => 0,
                Result::Err(_) => 0,
            }
            raise e;
        },
    }
    close(s)?;
    return 0;
}

/// Appends `text` to the file at `path`, creating it if needed. Needs `--allow-write`.
fn append_text(string path, string text) -> Result<int, IoError> {
    return append_bytes(path, to_bytes(text))?;
}
