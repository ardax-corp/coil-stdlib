// Byte-buffer helpers (userland). Indices are byte offsets; no UTF-8 awareness.
use string::{to_bytes, from_bytes};
use ascii::{hex_digit, hex_val};

class Bytes {
    buf: Vec<byte>,
}

impl Bytes {
    static fn from_vec(Vec<byte> buf) -> Bytes {
        return new Bytes(buf);
    }

    static fn to_vec(Bytes b) -> Vec<byte> {
        return b.buf;
    }
}

/// True when `a[ao..ao+n)` equals `b[bo..bo+n)` (caller guarantees bounds).
fn region_eq(Vec<byte> a, int ao, Vec<byte> b, int bo, int n) -> bool {
    let i = 0;
    let ok = true;
    while ok && i < n {
        if a[ao + i] != b[bo + i] {
            ok = false;
        }
        if ok {
            i = i + 1;
        }
    }
    return ok;
}

fn hex_nibble(int n) -> string {
    let b = hex_digit(n);
    let v: Vec<byte> = Vec::new();
    v.push(b);
    return match from_bytes(v) {
        Result::Ok(s) => s,
        Result::Err(_) => "",
    };
}

/// Hex-encode a byte buffer (lowercase).
fn to_hex(Vec<byte> buf) -> string {
    let out = "";
    let i = 0;
    while i < len(buf) {
        let v = buf[i] as int;
        out = out + hex_nibble(v / 16);
        out = out + hex_nibble(v % 16);
        i = i + 1;
    }
    return out;
}

/// Decode a lowercase/uppercase hex string into bytes.
fn from_hex(string s) -> Result<Vec<byte>, string> {
    let b = to_bytes(s);
    let n = len(b);
    if n % 2 != 0 {
        raise "invalid hex";
    }
    let out: Vec<byte> = Vec::new();
    let i = 0;
    while i < n {
        let hi = hex_val(b[i]);
        let lo = hex_val(b[i + 1]);
        if hi < 0 {
            raise "invalid hex";
        }
        if lo < 0 {
            raise "invalid hex";
        }
        let hi_i = hi as int;
        let lo_i = lo as int;
        let v = hi_i * 16 + lo_i;
        out.push(v as byte);
        i = i + 2;
    }
    return out;
}

/// Copy `src[start..end)` into a new buffer (clamped to `src` bounds).
fn slice(Vec<byte> src, int start, int end) -> Vec<byte> {
    let out: Vec<byte> = Vec::new();
    let i = start;
    if i < 0 {
        i = 0;
    }
    while i < end {
        if i < len(src) {
            out.push(src[i]);
        }
        i = i + 1;
    }
    return out;
}

/// Append `b` after `a` into a new buffer.
fn concat(Vec<byte> a, Vec<byte> b) -> Vec<byte> {
    let out: Vec<byte> = Vec::new();
    let i = 0;
    while i < len(a) {
        out.push(a[i]);
        i = i + 1;
    }
    let j = 0;
    while j < len(b) {
        out.push(b[j]);
        j = j + 1;
    }
    return out;
}

/// True when `a` and `b` have equal length and equal bytes.
fn eq(Vec<byte> a, Vec<byte> b) -> bool {
    if len(a) != len(b) {
        return false;
    }
    return region_eq(a, 0, b, 0, len(a));
}

/// First index of `needle` in `hay` at or after `start`, or `-1`.
fn find_from(Vec<byte> hay, Vec<byte> needle, int start) -> int {
    let hn = len(hay);
    let nn = len(needle);
    let i = start;
    if i < 0 {
        i = 0;
    }
    if i > hn {
        i = hn;
    }
    if nn == 0 {
        return i;
    }
    if nn > hn {
        return -1;
    }
    while i + nn <= hn {
        if region_eq(hay, i, needle, 0, nn) {
            return i;
        }
        i = i + 1;
    }
    return -1;
}

fn find(Vec<byte> hay, Vec<byte> needle) -> int {
    return find_from(hay, needle, 0);
}

fn rfind(Vec<byte> hay, Vec<byte> needle) -> int {
    let hn = len(hay);
    let nn = len(needle);
    if nn == 0 {
        return hn;
    }
    if nn > hn {
        return -1;
    }
    let i = hn - nn;
    while i >= 0 {
        if region_eq(hay, i, needle, 0, nn) {
            return i;
        }
        i = i - 1;
    }
    return -1;
}

fn contains(Vec<byte> hay, Vec<byte> needle) -> bool {
    return find(hay, needle) >= 0;
}

fn starts_with(Vec<byte> buf, Vec<byte> prefix) -> bool {
    let n = len(prefix);
    if n > len(buf) {
        return false;
    }
    return region_eq(buf, 0, prefix, 0, n);
}

fn ends_with(Vec<byte> buf, Vec<byte> suffix) -> bool {
    let n = len(suffix);
    let m = len(buf);
    if n > m {
        return false;
    }
    return region_eq(buf, m - n, suffix, 0, n);
}

fn copy(Vec<byte> src) -> Vec<byte> {
    let out: Vec<byte> = Vec::new();
    let i = 0;
    while i < len(src) {
        out.push(src[i]);
        i = i + 1;
    }
    return out;
}

fn replace(Vec<byte> hay, Vec<byte> old, Vec<byte> new) -> Vec<byte> {
    if len(old) == 0 {
        return copy(hay);
    }
    let out: Vec<byte> = Vec::new();
    let i = 0;
    let on = len(old);
    while i < len(hay) {
        let matches = i + on <= len(hay);
        if matches {
            matches = region_eq(hay, i, old, 0, on);
        }
        if matches {
            let k = 0;
            while k < len(new) {
                out.push(new[k]);
                k = k + 1;
            }
            i = i + on;
        } else {
            out.push(hay[i]);
            i = i + 1;
        }
    }
    return out;
}

fn repeat(Vec<byte> src, int n) -> Vec<byte> {
    let out: Vec<byte> = Vec::new();
    let count = 0;
    while count < n {
        let i = 0;
        while i < len(src) {
            out.push(src[i]);
            i = i + 1;
        }
        count = count + 1;
    }
    return out;
}

fn pad_left(Vec<byte> src, int width, byte fill) -> Vec<byte> {
    let out: Vec<byte> = Vec::new();
    let padding = width - len(src);
    let i = 0;
    while i < padding {
        out.push(fill);
        i = i + 1;
    }
    let j = 0;
    while j < len(src) {
        out.push(src[j]);
        j = j + 1;
    }
    return out;
}

fn pad_right(Vec<byte> src, int width, byte fill) -> Vec<byte> {
    let out: Vec<byte> = Vec::new();
    let j = 0;
    let n = len(src);
    while j < n {
        out.push(src[j]);
        j = j + 1;
    }
    let padding = width - n;
    let i = 0;
    while i < padding {
        out.push(fill);
        i = i + 1;
    }
    return out;
}

fn to_string(Vec<byte> b) -> Result<string, string> {
    return match from_bytes(b) {
        Result::Ok(s) => s,
        Result::Err(_) => raise "utf8",
    };
}

fn from_string(string s) -> Vec<byte> {
    return to_bytes(s);
}
