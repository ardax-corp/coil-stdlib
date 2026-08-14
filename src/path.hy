// Path value and filesystem helpers (userland). Forward slashes preferred; also accepts `\`.
use io::{IoError};
use io::fs::{
    exists as fs_exists,
    is_file as fs_is_file,
    is_dir as fs_is_dir,
    metadata as fs_metadata,
    list_dir as fs_list_dir,
    create_dir as fs_create_dir,
    create_dir_all as fs_create_dir_all,
    remove_file as fs_remove_file,
    rename as fs_rename,
    copy as fs_copy,
};
use io::file::{read_text, write_text, read_bytes, write_bytes, append_text, append_bytes};
use string::{to_bytes, from_bytes};
use bytes::{slice as bytes_slice, concat as bytes_concat};

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

    static fn from(string s) -> Path {
        return new Path(s);
    }

    fn as_str() -> string {
        return self.raw;
    }

    fn join(Path other) -> Result<Path, IoError> {
        let a = self.raw;
        let b = other.raw;
        if len(b) == 0 {
            return new Path(a);
        }
        if len(a) == 0 {
            return new Path(b);
        }
        let ab = to_bytes(a);
        let bb = to_bytes(b);
        let a_ends = Path::is_sep(ab[len(ab) - 1]);
        let b_starts = Path::is_sep(bb[0]);
        if a_ends {
            if b_starts {
                return match from_bytes(bytes_concat(ab, bytes_slice(bb, 1, len(bb)))) {
                    Result::Ok(s) => new Path(s),
                    Result::Err(e) => raise e,
                };
            }
            return match from_bytes(bytes_concat(ab, bb)) {
                Result::Ok(s) => new Path(s),
                Result::Err(e) => raise e,
            };
        }
        if b_starts {
            return match from_bytes(bytes_concat(ab, bb)) {
                Result::Ok(s) => new Path(s),
                Result::Err(e) => raise e,
            };
        }
        let slash: Vec<byte> = Vec::new();
        slash.push(47);
        return match from_bytes(bytes_concat(bytes_concat(ab, slash), bb)) {
            Result::Ok(s) => new Path(s),
            Result::Err(e) => raise e,
        };
    }

    fn dirname() -> Result<Path, IoError> {
        let path = self.raw;
        let b = to_bytes(path);
        let n = len(b);
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
                        Result::Err(e) => raise e,
                    };
                }
                return match from_bytes(bytes_slice(b, 0, i)) {
                    Result::Ok(s) => new Path(s),
                    Result::Err(e) => raise e,
                };
            }
        }
        return new Path(".");
    }

    fn basename() -> Result<string, IoError> {
        let path = self.raw;
        let b = to_bytes(path);
        let n = len(b);
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
                return from_bytes(bytes_slice(b, i + 1, end))?;
            }
        }
        return from_bytes(bytes_slice(b, 0, end))?;
    }

    fn extension() -> Result<string, IoError> {
        let base = self.basename()?;
        let b = to_bytes(base);
        let n = len(b);
        let i = n;
        while i > 0 {
            i = i - 1;
            if b[i] == "." {
                if i + 1 >= n {
                    return "";
                }
                return from_bytes(bytes_slice(b, i + 1, n))?;
            }
        }
        return "";
    }

    fn is_absolute() -> bool {
        let path = self.raw;
        let b = to_bytes(path);
        if len(b) == 0 {
            return false;
        }
        if Path::is_sep(b[0]) {
            return true;
        }
        if len(b) >= 2 {
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

    fn normalize() -> Result<Path, IoError> {
        let b = to_bytes(self.raw);
        let n = len(b);
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
                        Result::Err(e) => raise e,
                    };
                    if piece == ".." {
                        if len(parts) > 0 {
                            match parts.pop() {
                                Option::Some(_) => 0,
                                Option::None => 0,
                            };
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
        while j < len(parts) {
            if j > 0 {
                out.push(47);
            }
            let pb = to_bytes(parts[j]);
            let k = 0;
            while k < len(pb) {
                out.push(pb[k]);
                k = k + 1;
            }
            j = j + 1;
        }
        if len(out) == 0 {
            return new Path(".");
        }
        return match from_bytes(out) {
            Result::Ok(s) => new Path(s),
            Result::Err(e) => raise e,
        };
    }

    fn components() -> Result<Vec<string>, IoError> {
        let norm = self.normalize()?;
        let b = to_bytes(norm.raw);
        let out: Vec<string> = Vec::new();
        let n = len(b);
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
                    let piece = from_bytes(bytes_slice(b, start, i))?;
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

    fn exists() -> Result<bool, IoError> {
        return fs_exists(self.raw)?;
    }

    fn is_file() -> Result<bool, IoError> {
        return fs_is_file(self.raw)?;
    }

    fn is_dir() -> Result<bool, IoError> {
        return fs_is_dir(self.raw)?;
    }

    fn metadata() {
        return fs_metadata(self.raw)?;
    }

    fn list_dir() -> Result<Vec<string>, IoError> {
        return fs_list_dir(self.raw)?;
    }

    fn mkdir() -> Result<int, IoError> {
        fs_create_dir(self.raw)?;
        return 0;
    }

    fn mkdir_all() -> Result<int, IoError> {
        fs_create_dir_all(self.raw)?;
        return 0;
    }

    fn remove_file() -> Result<int, IoError> {
        fs_remove_file(self.raw)?;
        return 0;
    }

    fn rename(Path dst) -> Result<int, IoError> {
        fs_rename(self.raw, dst.raw)?;
        return 0;
    }

    fn copy_to(Path dst) -> Result<int, IoError> {
        fs_copy(self.raw, dst.raw)?;
        return 0;
    }

    fn read_text() -> Result<string, IoError> {
        return read_text(self.raw)?;
    }

    fn write_text(string text) -> Result<int, IoError> {
        return write_text(self.raw, text)?;
    }

    fn read_bytes() -> Result<Vec<byte>, IoError> {
        return read_bytes(self.raw)?;
    }

    fn write_bytes(Vec<byte> buf) -> Result<int, IoError> {
        return write_bytes(self.raw, buf)?;
    }

    fn append_text(string text) -> Result<int, IoError> {
        return append_text(self.raw, text)?;
    }

    fn append_bytes(Vec<byte> buf) -> Result<int, IoError> {
        return append_bytes(self.raw, buf)?;
    }
}
