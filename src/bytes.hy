// Byte-buffer helpers (userland). Indices are byte offsets; no UTF-8 awareness.
use string::{to_bytes, from_bytes};
use ascii::{hex_digit, hex_val};

/// A wrapper around a `Vec<byte>`, for APIs that want a distinct byte-buffer type.
///
/// The functions in this module work on plain `Vec<byte>`; convert with
/// `Bytes::from_vec` and `Bytes::to_vec`.
class Bytes {
    buf: Vec<byte>,
}

impl Bytes {
/// Wraps `buf` without copying it.
    pub static fn from_vec(Vec<byte> buf) -> Bytes {
        return new Bytes(buf);
    }

/// Returns the wrapped buffer.
    pub static fn to_vec(Bytes b) -> Vec<byte> {
        return b.buf;
    }
}

/// True when `a[ao..ao+n)` equals `b[bo..bo+n)` (caller guarantees bounds).
fn region_eq(Vec<byte> a, int ao, Vec<byte> b, int bo, int n) -> bool
    requires ao >= 0 && bo >= 0 && n >= 0
    requires ao + n <= a.len() && bo + n <= b.len()
{
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

/// Encodes `buf` as lowercase hexadecimal, two digits per byte.
///
/// # Examples
///
/// ```
/// use bytes::{to_hex};
/// # use tests::assert;
/// assert!(to_hex(Vec::from([0 as byte, 171 as byte, 255 as byte])) == "00abff");
/// ```
fn to_hex(Vec<byte> buf) -> string
    ensures result.len() == 2 * buf.len()
{
    let out = "";
    let i = 0;
    while i < buf.len() {
        let v = buf[i] as int;
        out = out + hex_nibble(v / 16);
        out = out + hex_nibble(v % 16);
        i = i + 1;
    }
    return out;
}

/// Decodes hexadecimal text (either case) into bytes.
///
/// # Errors
///
/// Returns `Err` when `s` has an odd length or a character that is not a hex digit.
///
/// # Examples
///
/// ```
/// use bytes::{from_hex};
/// # use tests::assert;
/// let b = from_hex("00AbfF") ?? Vec::new();
/// assert!(b.len() == 3 && b[1] == 171 as byte);
/// assert!(from_hex("abc").is_err());
/// ```
fn from_hex(string s) -> Result<Vec<byte>, string> {
    let b = to_bytes(s);
    let n = b.len();
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

/// Returns a copy of `src[start..end]` (end exclusive), with both offsets clamped to the buffer.
///
/// # Examples
///
/// ```
/// use bytes::{slice};
/// # use tests::assert;
/// let b: Vec<byte> = "hello";
/// assert!(slice(b, 1, 3).len() == 2);
/// assert!(slice(b, 3, 99).len() == 2);
/// ```
fn slice(Vec<byte> src, int start, int end) -> Vec<byte>
    ensures result.len() <= src.len()
    ensures start < end || result.len() == 0
{
    let out: Vec<byte> = Vec::new();
    let i = start;
    if i < 0 {
        i = 0;
    }
    while i < end {
        if i < src.len() {
            out.push(src[i]);
        }
        i = i + 1;
    }
    return out;
}

/// Returns a new buffer holding `a` followed by `b`.
fn concat(Vec<byte> a, Vec<byte> b) -> Vec<byte>
    ensures result.len() == a.len() + b.len()
    ensures starts_with(result, a) && ends_with(result, b)
{
    let out: Vec<byte> = Vec::new();
    let i = 0;
    while i < a.len() {
        out.push(a[i]);
        i = i + 1;
    }
    let j = 0;
    while j < b.len() {
        out.push(b[j]);
        j = j + 1;
    }
    return out;
}

/// Returns `true` when `a` and `b` have the same length and the same bytes.
fn eq(Vec<byte> a, Vec<byte> b) -> bool
    ensures !result || a.len() == b.len()
{
    if a.len() != b.len() {
        return false;
    }
    return region_eq(a, 0, b, 0, a.len());
}

/// Returns the offset of the first `needle` in `hay` at or after `start`, or `-1`.
fn find_from(Vec<byte> hay, Vec<byte> needle, int start) -> int
    ensures result >= -1 && result <= hay.len()
    ensures result < 0 || result >= start || (start > hay.len() && result == hay.len())
    ensures result < 0 ||
            (result + needle.len() <= hay.len() && region_eq(hay, result, needle, 0, needle.len()))
{
    let hn = hay.len();
    let nn = needle.len();
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

/// Returns the offset of the first `needle` in `hay`, or `-1`. An empty `needle` matches at `0`.
///
/// # Examples
///
/// ```
/// use bytes::{find};
/// # use tests::assert;
/// assert!(find("a,b,c", ",") == 1);
/// assert!(find("abc", "x") == -1);
/// ```
fn find(Vec<byte> hay, Vec<byte> needle) -> int {
    return find_from(hay, needle, 0);
}

/// Returns the offset of the last `needle` in `hay`, or `-1`. An empty `needle` matches at `hay.len()`.
///
/// # Examples
///
/// ```
/// use bytes::{rfind};
/// # use tests::assert;
/// assert!(rfind("a,b,c", ",") == 3);
/// ```
fn rfind(Vec<byte> hay, Vec<byte> needle) -> int
    ensures result >= -1 && result <= hay.len()
    ensures result < 0 ||
            (result + needle.len() <= hay.len() && region_eq(hay, result, needle, 0, needle.len()))
{
    let hn = hay.len();
    let nn = needle.len();
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

/// Returns `true` when `needle` occurs in `hay`.
fn contains(Vec<byte> hay, Vec<byte> needle) -> bool
    ensures !result || needle.len() <= hay.len()
{
    return find(hay, needle) >= 0;
}

/// Returns `true` when `buf` begins with `prefix`.
///
/// # Examples
///
/// ```
/// use bytes::{starts_with};
/// # use tests::assert;
/// assert!(starts_with("GET /", "GET"));
/// assert!(!starts_with("GE", "GET"));
/// ```
fn starts_with(Vec<byte> buf, Vec<byte> prefix) -> bool
    ensures !result || prefix.len() <= buf.len()
{
    let n = prefix.len();
    if n > buf.len() {
        return false;
    }
    return region_eq(buf, 0, prefix, 0, n);
}

/// Returns `true` when `buf` ends with `suffix`.
fn ends_with(Vec<byte> buf, Vec<byte> suffix) -> bool
    ensures !result || suffix.len() <= buf.len()
{
    let n = suffix.len();
    let m = buf.len();
    if n > m {
        return false;
    }
    return region_eq(buf, m - n, suffix, 0, n);
}

/// Returns a new buffer with the same bytes as `src`.
fn copy(Vec<byte> src) -> Vec<byte>
    ensures eq(result, src)
{
    let out: Vec<byte> = Vec::new();
    let i = 0;
    while i < src.len() {
        out.push(src[i]);
        i = i + 1;
    }
    return out;
}

/// Returns a copy of `hay` with every non-overlapping `old` replaced by `new`, left to right.
///
/// An empty `old` replaces nothing.
///
/// # Examples
///
/// ```
/// use bytes::{replace, to_string};
/// # use tests::assert;
/// let out = replace("a-b-c", "-", "+");
/// assert!((to_string(out) ?? "") == "a+b+c");
/// ```
fn replace(Vec<byte> hay, Vec<byte> old, Vec<byte> new) -> Vec<byte>
    ensures old.len() > 0 || eq(result, hay)
    ensures old.len() == 0 || contains(hay, old) || eq(result, hay)
{
    if old.len() == 0 {
        return copy(hay);
    }
    let out: Vec<byte> = Vec::new();
    let i = 0;
    let on = old.len();
    while i < hay.len() {
        let matches = i + on <= hay.len();
        if matches {
            matches = region_eq(hay, i, old, 0, on);
        }
        if matches {
            let k = 0;
            while k < new.len() {
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

/// Returns `src` repeated `n` times (empty when `n <= 0`).
fn repeat(Vec<byte> src, int n) -> Vec<byte>
    ensures n > 0 || result.len() == 0
    ensures n <= 0 || result.len() == src.len() * n
{
    let out: Vec<byte> = Vec::new();
    let count = 0;
    while count < n {
        let i = 0;
        while i < src.len() {
            out.push(src[i]);
            i = i + 1;
        }
        count = count + 1;
    }
    return out;
}

/// Returns `src` with `fill` bytes added in front until it is `width` long; a longer `src` is returned unchanged.
///
/// # Examples
///
/// ```
/// use bytes::{pad_left, to_string};
/// # use tests::assert;
/// let zero: byte = "0";
/// assert!((to_string(pad_left("42", 5, zero)) ?? "") == "00042");
/// ```
fn pad_left(Vec<byte> src, int width, byte fill) -> Vec<byte>
    ensures result.len() >= src.len() && result.len() >= width
    ensures result.len() == src.len() || result.len() == width
    ensures ends_with(result, src)
{
    let out: Vec<byte> = Vec::new();
    let padding = width - src.len();
    let i = 0;
    while i < padding {
        out.push(fill);
        i = i + 1;
    }
    let j = 0;
    while j < src.len() {
        out.push(src[j]);
        j = j + 1;
    }
    return out;
}

/// Returns `src` with `fill` bytes added at the end until it is `width` long; a longer `src` is returned unchanged.
fn pad_right(Vec<byte> src, int width, byte fill) -> Vec<byte>
    ensures result.len() >= src.len() && result.len() >= width
    ensures result.len() == src.len() || result.len() == width
    ensures starts_with(result, src)
{
    let out: Vec<byte> = Vec::new();
    let j = 0;
    let n = src.len();
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

/// Decodes `b` as UTF-8.
///
/// # Errors
///
/// Returns `Err("utf8")` when `b` is not valid UTF-8. `string::from_bytes` does
/// the same with an `IoError`.
fn to_string(Vec<byte> b) -> Result<string, string> {
    return match from_bytes(b) {
        Result::Ok(s) => s,
        Result::Err(_) => raise "utf8",
    };
}

/// Returns the UTF-8 bytes of `s`; the same as `string::to_bytes`.
fn from_string(string s) -> Vec<byte>
    ensures result.len() == s.len()
{
    return to_bytes(s);
}
