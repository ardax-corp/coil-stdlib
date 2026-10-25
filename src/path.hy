// Path value and filesystem helpers (userland). Forward slashes preferred; also accepts `\`.
use io::IoError;
use io::fs::exists as fs_exists;
use io::fs::is_file as fs_is_file;
use io::fs::is_dir as fs_is_dir;
use io::fs::metadata as fs_metadata;
use io::fs::list_dir as fs_list_dir;
use io::fs::create_dir as fs_create_dir;
use io::fs::create_dir_all as fs_create_dir_all;
use io::fs::remove_file as fs_remove_file;
use io::fs::rename as fs_rename;
use io::fs::copy as fs_copy;
use io::file::read_text;
use io::file::write_text;
use io::file::read_bytes;
use io::file::write_bytes;
use io::file::append_text;
use io::file::append_bytes;
use string::{to_bytes, from_bytes};
use bytes::{slice as bytes_slice, concat as bytes_concat};

// A path piece as text; bytes that are not UTF-8 are `InvalidInput`.
fn utf8_path(Vec<byte> b) -> Result<string, IoError> {
    return match from_bytes(b) {
        Result::Ok(s) => s,
        Result::Err(_) => raise IoError::InvalidInput,
    };
}

/// A file-system path, with helpers to take it apart and to use it.
///
/// `Path` is plain text: building one never touches the disk. Both `/` and `\\`
/// separate components; `join` and `normalize` write `/`. The file-system methods
/// (`exists`, `read_text`, `mkdir`, …) call `io::fs` and `io::file`, so they need
/// the same `--allow-read` / `--allow-write` grants.
///
/// # Examples
///
/// ```
/// use path::{Path};
/// # use tests::assert;
/// let p = Path::from("/srv/app/../data/report.csv").normalize().ok() ?? Path::from("");
/// assert!(p.as_str() == "/srv/data/report.csv");
/// assert!((p.basename().ok() ?? "") == "report.csv");
/// assert!((p.extension().ok() ?? "") == "csv");
/// assert!((p.dirname().ok() ?? p).as_str() == "/srv/data");
/// ```
class Path {
    raw: string,
}

impl Path {
    static fn is_sep(byte c) -> bool {
        let slash: byte = "/";
        let bslash: byte = "\\";
        if c == slash {
            return true;
        }
        if c == bslash {
            return true;
        }
        return false;
    }

    /// Creates a path from `s` as written.
    pub static fn from(string s) -> Path {
        return new Path(s);
    }

    /// Returns the path as a string.
    pub fn as_str() -> string {
        return self.raw;
    }

    /// Returns this path followed by `other`, with exactly one separator between them.
    ///
    /// An empty side returns the other one unchanged. `other` is appended even when
    /// it is absolute.
    ///
    /// # Examples
    ///
    /// ```
    /// use path::{Path};
    /// # use tests::assert;
    /// let p = Path::from("logs/").join(Path::from("/today.txt")).ok() ?? Path::from("");
    /// assert!(p.as_str() == "logs/today.txt");
    /// assert!((Path::from("a").join(Path::from("b")).ok() ?? Path::from("")).as_str() == "a/b");
    /// ```
    pub fn join(Path other) -> Result<Path, IoError> {
        let a = self.raw;
        let b = other.raw;
        if b.len() == 0 {
            return new Path(a);
        }
        if a.len() == 0 {
            return new Path(b);
        }
        let ab = to_bytes(a);
        let bb = to_bytes(b);
        let a_ends = Path::is_sep(ab[ab.len() - 1]);
        let b_starts = Path::is_sep(bb[0]);
        if a_ends {
            if b_starts {
                return match from_bytes(bytes_concat(ab, bytes_slice(bb, 1, bb.len()))) {
                    Result::Ok(s) => new Path(s),
                    Result::Err(_) => raise IoError::InvalidInput,
                };
            }
            return match from_bytes(bytes_concat(ab, bb)) {
                Result::Ok(s) => new Path(s),
                Result::Err(_) => raise IoError::InvalidInput,
            };
        }
        if b_starts {
            return match from_bytes(bytes_concat(ab, bb)) {
                Result::Ok(s) => new Path(s),
                Result::Err(_) => raise IoError::InvalidInput,
            };
        }
        let slash: Vec<byte> = Vec::new();
        slash.push(47);
        return match from_bytes(bytes_concat(bytes_concat(ab, slash), bb)) {
            Result::Ok(s) => new Path(s),
            Result::Err(_) => raise IoError::InvalidInput,
        };
    }

    /// Returns the path without its last component.
    ///
    /// Trailing separators are ignored. A path with no separator gives `.`; a
    /// path directly under the root gives `/`.
    ///
    /// # Examples
    ///
    /// ```
    /// use path::{Path};
    /// # use tests::assert;
    /// assert!((Path::from("a/b/c.txt").dirname().ok() ?? Path::from("")).as_str() == "a/b");
    /// assert!((Path::from("/top").dirname().ok() ?? Path::from("")).as_str() == "/");
    /// assert!((Path::from("file").dirname().ok() ?? Path::from("")).as_str() == ".");
    /// ```
    pub fn dirname() -> Result<Path, IoError> {
        let path = self.raw;
        let b = to_bytes(path);
        let n = b.len();
        if n == 0 {
            return new Path(".");
        }
        let end = n;
        while end > 1 {
            if Path::is_sep(b[end - 1]) {
                end = end - 1;
            }
            if end > 1 {
                if Path::is_sep(b[end - 1]) == false {
                    break;
                }
            }
            if end <= 1 {
                break;
            }
        }
        let i = end;
        while i > 0 {
            i = i - 1;
            if Path::is_sep(b[i]) {
                if i == 0 {
                    return match from_bytes(bytes_slice(b, 0, 1)) {
                        Result::Ok(s) => new Path(s),
                        Result::Err(_) => raise IoError::InvalidInput,
                    };
                }
                return match from_bytes(bytes_slice(b, 0, i)) {
                    Result::Ok(s) => new Path(s),
                    Result::Err(_) => raise IoError::InvalidInput,
                };
            }
        }
        return new Path(".");
    }

    /// Returns the last component, ignoring trailing separators (`""` for an empty path or `/`).
    ///
    /// # Examples
    ///
    /// ```
    /// use path::{Path};
    /// # use tests::assert;
    /// assert!((Path::from("a/b/c.txt").basename().ok() ?? "") == "c.txt");
    /// assert!((Path::from("a/b/").basename().ok() ?? "") == "b");
    /// ```
    pub fn basename() -> Result<string, IoError> {
        let path = self.raw;
        let b = to_bytes(path);
        let n = b.len();
        if n == 0 {
            return "";
        }
        let end = n;
        while end > 0 {
            if Path::is_sep(b[end - 1]) {
                end = end - 1;
            }
            if end > 0 {
                if Path::is_sep(b[end - 1]) == false {
                    break;
                }
            }
            if end <= 0 {
                break;
            }
        }
        if end == 0 {
            return "";
        }
        let i = end;
        while i > 0 {
            i = i - 1;
            if Path::is_sep(b[i]) {
                return utf8_path(bytes_slice(b, i + 1, end))?;
            }
        }
        return utf8_path(bytes_slice(b, 0, end))?;
    }

    /// Returns the text after the last `.` of the last component, or `""` when there is none.
    ///
    /// # Examples
    ///
    /// ```
    /// use path::{Path};
    /// # use tests::assert;
    /// assert!((Path::from("archive.tar.gz").extension().ok() ?? "") == "gz");
    /// assert!((Path::from("Makefile").extension().ok() ?? "") == "");
    /// ```
    pub fn extension() -> Result<string, IoError> {
        let base = self.basename()?;
        let b = to_bytes(base);
        let n = b.len();
        let i = n;
        while i > 0 {
            i = i - 1;
            if b[i] == "." {
                if i + 1 >= n {
                    return "";
                }
                return utf8_path(bytes_slice(b, i + 1, n))?;
            }
        }
        return "";
    }

    /// Returns `true` when the path starts with a separator or a Windows drive letter (`C:`).
    ///
    /// # Examples
    ///
    /// ```
    /// use path::{Path};
    /// # use tests::assert;
    /// assert!(Path::from("/etc").is_absolute());
    /// assert!(Path::from("C:\\data").is_absolute());
    /// assert!(!Path::from("src/main.hy").is_absolute());
    /// ```
    pub fn is_absolute() -> bool {
        let path = self.raw;
        let b = to_bytes(path);
        if b.len() == 0 {
            return false;
        }
        if Path::is_sep(b[0]) {
            return true;
        }
        if b.len() >= 2 {
            if b[0] >= "A" {
                if b[0] <= "Z" {
                    if b[1] == ":" {
                        return true;
                    }
                }
            }
            if b[0] >= "a" {
                if b[0] <= "z" {
                    if b[1] == ":" {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    /// Removes `.` components, resolves `..` against the component before it, and collapses repeated separators.
    ///
    /// Purely textual: symlinks are not followed (use `io::fs::realpath` for that),
    /// and a `..` with nothing before it is dropped. An empty result is `.`.
    ///
    /// # Examples
    ///
    /// ```
    /// use path::{Path};
    /// # use tests::assert;
    /// assert!((Path::from("a/./b//../c").normalize().ok() ?? Path::from("")).as_str() == "a/c");
    /// assert!((Path::from("/../x").normalize().ok() ?? Path::from("")).as_str() == "/x");
    /// ```
    pub fn normalize() -> Result<Path, IoError> {
        let b = to_bytes(self.raw);
        let n = b.len();
        if n == 0 {
            return new Path(".");
        }
        let leading = Path::is_sep(b[0]);
        let parts: Vec<string> = Vec::new();
        let start = 0;
        let i = 0;
        while i <= n {
            let at_end = i == n;
            let is_slash = false;
            if !at_end {
                is_slash = Path::is_sep(b[i]);
            }
            if at_end || is_slash {
                if i > start {
                    let piece = match from_bytes(bytes_slice(b, start, i)) {
                        Result::Ok(s) => s,
                        Result::Err(_) => raise IoError::InvalidInput,
                    };
                    if piece == ".." {
                        if parts.len() > 0 {
                            match parts.pop() {
                                Option::Some(_) => 0,
                                Option::None => 0,
                            }
                        }
                    } else {
                        if piece != "." {
                            parts.push(piece);
                        }
                    }
                }
                start = i + 1;
            }
            if at_end {
                break;
            }
            i = i + 1;
        }
        let out: Vec<byte> = Vec::new();
        if leading {
            out.push(47);
        }
        let j = 0;
        while j < parts.len() {
            if j > 0 {
                out.push(47);
            }
            let pb = to_bytes(parts[j]);
            let k = 0;
            while k < pb.len() {
                out.push(pb[k]);
                k = k + 1;
            }
            j = j + 1;
        }
        if out.len() == 0 {
            return new Path(".");
        }
        return match from_bytes(out) {
            Result::Ok(s) => new Path(s),
            Result::Err(_) => raise IoError::InvalidInput,
        };
    }

    /// Returns the components of the normalized path, without separators.
    ///
    /// # Examples
    ///
    /// ```
    /// use path::{Path};
    /// # use tests::assert;
    /// let parts = Path::from("/usr/local/../bin").components().ok() ?? Vec::new();
    /// assert!(parts.len() == 2);
    /// assert!(parts[0] == "usr" && parts[1] == "bin");
    /// ```
    pub fn components() -> Result<Vec<string>, IoError> {
        let norm = self.normalize()?;
        let b = to_bytes(norm.raw);
        let out: Vec<string> = Vec::new();
        let n = b.len();
        if n == 0 {
            return out;
        }
        let start = 0;
        if Path::is_sep(b[0]) {
            start = 1;
        }
        let i = start;
        while i <= n {
            let at_end = i == n;
            let is_slash = false;
            if !at_end {
                is_slash = Path::is_sep(b[i]);
            }
            if at_end || is_slash {
                if i > start {
                    let piece = utf8_path(bytes_slice(b, start, i))?;
                    out.push(piece);
                }
                start = i + 1;
            }
            if at_end {
                break;
            }
            i = i + 1;
        }
        return out;
    }

    /// Returns whether something exists at this path. See `io::fs::exists`.
    pub fn exists() -> Result<bool, IoError> {
        return fs_exists(self.raw)?;
    }

    /// Returns whether this path is a regular file. See `io::fs::is_file`.
    pub fn is_file() -> Result<bool, IoError> {
        return fs_is_file(self.raw)?;
    }

    /// Returns whether this path is a directory. See `io::fs::is_dir`.
    pub fn is_dir() -> Result<bool, IoError> {
        return fs_is_dir(self.raw)?;
    }

    /// Returns the file's metadata. See `io::fs::metadata`.
    pub fn metadata() {
        return fs_metadata(self.raw)?;
    }

    /// Returns the names of the entries in this directory. See `io::fs::list_dir`.
    pub fn list_dir() -> Result<Vec<string>, IoError> {
        return fs_list_dir(self.raw)?;
    }

    /// Creates this directory; its parent must exist. See `io::fs::create_dir`.
    pub fn mkdir() -> Result<int, IoError> {
        fs_create_dir(self.raw)?;
        return 0;
    }

    /// Creates this directory and any missing parents. See `io::fs::create_dir_all`.
    pub fn mkdir_all() -> Result<int, IoError> {
        fs_create_dir_all(self.raw)?;
        return 0;
    }

    /// Deletes the file at this path. See `io::fs::remove_file`.
    pub fn remove_file() -> Result<int, IoError> {
        fs_remove_file(self.raw)?;
        return 0;
    }

    /// Moves this file or directory to `dst`. See `io::fs::rename`.
    pub fn rename(Path dst) -> Result<int, IoError> {
        fs_rename(self.raw, dst.raw)?;
        return 0;
    }

    /// Copies this file to `dst`, replacing it. See `io::fs::copy`.
    pub fn copy_to(Path dst) -> Result<int, IoError> {
        fs_copy(self.raw, dst.raw)?;
        return 0;
    }

    /// Reads the whole file as UTF-8 text. See `io::file::read_text`.
    pub fn read_text() -> Result<string, IoError> {
        return read_text(self.raw)?;
    }

    /// Replaces the file's contents with `text` and returns the number of bytes written. See `io::file::write_text`.
    pub fn write_text(string text) -> Result<int, IoError> {
        return write_text(self.raw, text)?;
    }

    /// Reads the whole file. See `io::file::read_bytes`.
    pub fn read_bytes() -> Result<Vec<byte>, IoError> {
        return read_bytes(self.raw)?;
    }

    /// Replaces the file's contents with `buf`. See `io::file::write_bytes`.
    pub fn write_bytes(Vec<byte> buf) -> Result<int, IoError> {
        return write_bytes(self.raw, buf)?;
    }

    /// Appends `text` to the file, creating it if needed. See `io::file::append_text`.
    pub fn append_text(string text) -> Result<int, IoError> {
        return append_text(self.raw, text)?;
    }

    /// Appends `buf` to the file, creating it if needed. See `io::file::append_bytes`.
    pub fn append_bytes(Vec<byte> buf) -> Result<int, IoError> {
        return append_bytes(self.raw, buf)?;
    }
}
