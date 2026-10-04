// String helpers on byte offsets (userland).
// Byte-oriented offsets — slicing mid-codepoint yields UTF-8 errors.
// Named `text` because virtual `string` already owns `format` / `to_bytes` / `from_bytes`.
// The search and slice helpers use the `string` byte natives, which read the
// string in place instead of copying it through `to_bytes` on every call.
use string::{
    to_bytes,
    from_bytes,
    byte_at,
    slice_bytes,
    find_from as str_find_from,
    rfind as str_rfind,
    match_at,
};
use ascii::{is_space};

fn utf8_ok(Vec<byte> b) -> Result<string, string> {
    return match from_bytes(b) {
        Result::Ok(s) => s,
        Result::Err(_) => raise "utf8",
    };
}

fn sub(string s, int start, int end) -> Result<string, string> {
    return match slice_bytes(s, start, end) {
        Result::Ok(x) => x,
        Result::Err(_) => raise "utf8",
    };
}

fn space_at(string s, int i) -> bool {
    return is_space(byte_at(s, i) as byte);
}

/// Byte length of UTF-8 `s` (same as `len(to_bytes(s))`).
fn byte_len(string s) -> int {
    return len(s);
}

/// Slice by byte offsets; returns `Err` if the slice is not valid UTF-8.
fn slice(string s, int start, int end) -> Result<string, string> {
    return sub(s, start, end)?;
}

/// Trim ASCII whitespace from the start.
fn trim_start(string s) -> Result<string, string> {
    let lo = 0;
    let hi = len(s);
    while lo < hi && space_at(s, lo) {
        lo = lo + 1;
    }
    return sub(s, lo, hi)?;
}

/// Trim ASCII whitespace from the end.
fn trim_end(string s) -> Result<string, string> {
    let hi = len(s);
    while hi > 0 && space_at(s, hi - 1) {
        hi = hi - 1;
    }
    return sub(s, 0, hi)?;
}

/// Trim ASCII whitespace (space/tab/CR/LF) from both ends.
fn trim(string s) -> Result<string, string> {
    let lo = 0;
    let hi = len(s);
    while lo < hi && space_at(s, lo) {
        lo = lo + 1;
    }
    while hi > lo && space_at(s, hi - 1) {
        hi = hi - 1;
    }
    return sub(s, lo, hi)?;
}

/// True when `hay` contains `needle` as a byte-exact substring.
fn contains(string hay, string needle) -> bool {
    return str_find_from(hay, needle, 0) >= 0;
}

/// True when `s` begins with `prefix` (byte identity).
fn starts_with(string s, string prefix) -> bool {
    return match_at(s, prefix, 0);
}

/// True when `s` ends with `suffix` (byte identity).
fn ends_with(string s, string suffix) -> bool {
    return match_at(s, suffix, len(s) - len(suffix));
}

/// First byte offset of `needle` in `hay`, or `-1`. Empty needle → `0`.
fn find(string hay, string needle) -> int {
    return str_find_from(hay, needle, 0);
}

/// Last byte offset of `needle` in `hay`, or `-1`.
fn rfind(string hay, string needle) -> int {
    return str_rfind(hay, needle);
}

/// Split at byte offset `at` into `(left, right)`.
fn split_at(string s, int at) -> Result<(string, string), string> {
    if at < 0 {
        at = 0;
    }
    if at > len(s) {
        at = len(s);
    }
    let left = sub(s, 0, at)?;
    let right = sub(s, at, len(s))?;
    return (left, right);
}

/// Split `s` on every occurrence of `sep` (byte-exact). Empty sep → `[s]`.
fn split(string s, string sep) -> Result<Vec<string>, string> {
    let out: Vec<string> = Vec::new();
    let nn = len(sep);
    if nn == 0 {
        out.push(s);
        return out;
    }
    let start = 0;
    let at = str_find_from(s, sep, 0);
    while at >= 0 {
        let part = sub(s, start, at)?;
        out.push(part);
        start = at + nn;
        at = str_find_from(s, sep, start);
    }
    let last = sub(s, start, len(s))?;
    out.push(last);
    return out;
}

/// Split at the first occurrence of `sep`, excluding the separator.
fn split_once(string s, string sep) -> Result<(string, string), string> {
    let at = str_find_from(s, sep, 0);
    if at < 0 {
        raise "separator not found";
    }
    let left = sub(s, 0, at)?;
    let right = sub(s, at + len(sep), len(s))?;
    return (left, right);
}

/// Replace every non-overlapping occurrence of `old` with `new`.
fn replace(string s, string old, string new) -> Result<string, string> {
    let nn = len(old);
    if nn == 0 {
        return s;
    }
    let out = "";
    let start = 0;
    let at = str_find_from(s, old, 0);
    while at >= 0 {
        out = out + sub(s, start, at)? + new;
        start = at + nn;
        at = str_find_from(s, old, start);
    }
    return out + sub(s, start, len(s))?;
}

/// Join strings with `sep` between adjacent parts.
fn join(Vec<string> parts, string sep) -> string {
    let out = "";
    let i = 0;
    while i < len(parts) {
        if i > 0 {
            out = out + sep;
        }
        out = out + parts[i];
        i = i + 1;
    }
    return out;
}

/// Repeat `s` `n` times. Non-positive counts produce an empty string.
fn repeat(string s, int n) -> string {
    let out = "";
    let i = 0;
    while i < n {
        out = out + s;
        i = i + 1;
    }
    return out;
}

/// Pad on the left to a byte width using a one-byte `fill` string.
fn pad_left(string s, int width, string fill) -> Result<string, string> {
    if len(fill) != 1 {
        raise "fill must be one byte";
    }
    return repeat(fill, width - len(s)) + s;
}

/// Pad on the right to a byte width using a one-byte `fill` string.
fn pad_right(string s, int width, string fill) -> Result<string, string> {
    if len(fill) != 1 {
        raise "fill must be one byte";
    }
    return s + repeat(fill, width - len(s));
}

fn line_piece(string s, int start, int end) -> Result<string, string> {
    if end > start && match_at(s, "\r", end - 1) {
        end = end - 1;
    }
    return sub(s, start, end)?;
}

/// Split on LF and strip one optional CR from each resulting line.
fn lines(string s) -> Result<Vec<string>, string> {
    let out: Vec<string> = Vec::new();
    let start = 0;
    let at = str_find_from(s, "\n", 0);
    while at >= 0 {
        let piece = line_piece(s, start, at)?;
        out.push(piece);
        start = at + 1;
        at = str_find_from(s, "\n", start);
    }
    let last = line_piece(s, start, len(s))?;
    out.push(last);
    return out;
}

/// Concatenate two strings.
fn concat(string a, string b) -> string {
    return a + b;
}

/// True when strings are equal (byte identity).
fn eq(string a, string b) -> bool {
    return a == b;
}

/// ASCII lower-case A..=Z only; other bytes unchanged.
fn to_lower(string s) -> Result<string, string> {
    let b = to_bytes(s);
    let out: Vec<byte> = Vec::new();
    let i = 0;
    let a_up: byte = "A";
    let z_up: byte = "Z";
    while i < len(b) {
        let c = b[i];
        if c >= a_up {
            if c <= z_up {
                let n = (c as int) + 32;
                let lo = n as byte;
                out.push(lo);
            }
            if c > z_up {
                out.push(c);
            }
        }
        if c < a_up {
            out.push(c);
        }
        i = i + 1;
    }
    return utf8_ok(out)?;
}

/// ASCII upper-case a..=z only; other bytes unchanged.
fn to_upper(string s) -> Result<string, string> {
    let b = to_bytes(s);
    let out: Vec<byte> = Vec::new();
    let i = 0;
    let a_lo: byte = "a";
    let z_lo: byte = "z";
    while i < len(b) {
        let c = b[i];
        if c >= a_lo {
            if c <= z_lo {
                let n = (c as int) - 32;
                let up = n as byte;
                out.push(up);
            }
            if c > z_lo {
                out.push(c);
            }
        }
        if c < a_lo {
            out.push(c);
        }
        i = i + 1;
    }
    return utf8_ok(out)?;
}
