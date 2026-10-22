// String helpers on byte offsets (userland).
// Byte-oriented offsets — slicing mid-codepoint yields UTF-8 errors.
// Named `text` because virtual `string` already owns `format` / `to_bytes` / `from_bytes`.
// The search and slice helpers use the `string` byte natives, which read the
// string in place instead of copying it through `to_bytes` on every call.
use string::{to_bytes, from_bytes, byte_at, slice_bytes, find_from as str_find_from, rfind as str_rfind, match_at};
use ascii::is_space;

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

// Length of an `Ok` string, `-1` for an `Err` (for contracts).
fn ok_len(Result<string, string> r) -> int {
    return match r {
        Result::Ok(x) => x.len(),
        Result::Err(_) => -1,
    };
}

fn max_int(int a, int b) -> int {
    if a > b {
        return a;
    }
    return b;
}

fn space_at(string s, int i) -> bool {
    return is_space(byte_at(s, i) as byte);
}

/// Returns the length of `s` in bytes; the same as `s.len()`.
fn byte_len(string s) -> int {
    return s.len();
}

/// Returns the part of `s` from byte offset `start` up to (not including) `end`.
///
/// # Errors
///
/// Returns `Err("utf8")` when an offset falls inside a multi-byte character.
///
/// # Examples
///
/// ```
/// use text::{slice};
/// # use tests::assert;
/// assert!((slice("hello", 1, 4) ?? "") == "ell");
/// ```
fn slice(string s, int start, int end) -> Result<string, string> {
    return sub(s, start, end)?;
}

/// Returns `s` without leading ASCII whitespace (space, tab, CR, LF).
///
/// # Examples
///
/// ```
/// use text::{trim_start};
/// # use tests::assert;
/// assert!((trim_start("  hi ") ?? "") == "hi ");
/// ```
fn trim_start(string s) -> Result<string, string>
    ensures ok_len(result) >= 0 && ok_len(result) <= s.len()
{
    let lo = 0;
    let hi = s.len();
    while lo < hi && space_at(s, lo) {
        lo = lo + 1;
    }
    return sub(s, lo, hi)?;
}

/// Returns `s` without trailing ASCII whitespace (space, tab, CR, LF).
///
/// # Examples
///
/// ```
/// use text::{trim_end};
/// # use tests::assert;
/// assert!((trim_end(" hi \n") ?? "") == " hi");
/// ```
fn trim_end(string s) -> Result<string, string>
    ensures ok_len(result) >= 0 && ok_len(result) <= s.len()
{
    let hi = s.len();
    while hi > 0 && space_at(s, hi - 1) {
        hi = hi - 1;
    }
    return sub(s, 0, hi)?;
}

/// Returns `s` without leading and trailing ASCII whitespace (space, tab, CR, LF).
///
/// Other Unicode whitespace is kept. The `Result` never holds an error for valid
/// input; it exists because trimming works on bytes.
///
/// # Examples
///
/// ```
/// use text::{trim};
/// # use tests::assert;
/// assert!((trim("\t  key = value \r\n") ?? "") == "key = value");
/// ```
fn trim(string s) -> Result<string, string>
    ensures ok_len(result) >= 0 && ok_len(result) <= s.len()
{
    let lo = 0;
    let hi = s.len();
    while lo < hi && space_at(s, lo) {
        lo = lo + 1;
    }
    while hi > lo && space_at(s, hi - 1) {
        hi = hi - 1;
    }
    return sub(s, lo, hi)?;
}

/// Returns `true` when `needle` occurs in `hay`. An empty `needle` is always found.
///
/// # Examples
///
/// ```
/// use text::{contains};
/// # use tests::assert;
/// assert!(contains("haystack", "st"));
/// assert!(!contains("haystack", "x"));
/// ```
fn contains(string hay, string needle) -> bool
    ensures !result || needle.len() <= hay.len()
{
    return str_find_from(hay, needle, 0) >= 0;
}

/// Returns `true` when `s` begins with `prefix`.
///
/// # Examples
///
/// ```
/// use text::{starts_with};
/// # use tests::assert;
/// assert!(starts_with("--verbose", "--"));
/// ```
fn starts_with(string s, string prefix) -> bool
    ensures !result || prefix.len() <= s.len()
{
    return match_at(s, prefix, 0);
}

/// Returns `true` when `s` ends with `suffix`.
///
/// # Examples
///
/// ```
/// use text::{ends_with};
/// # use tests::assert;
/// assert!(ends_with("main.hy", ".hy"));
/// ```
fn ends_with(string s, string suffix) -> bool
    ensures !result || suffix.len() <= s.len()
{
    return match_at(s, suffix, s.len() - suffix.len());
}

/// Returns the byte offset of the first `needle` in `hay`, or `-1`. An empty `needle` matches at `0`.
///
/// # Examples
///
/// ```
/// use text::{find};
/// # use tests::assert;
/// assert!(find("a=b=c", "=") == 1);
/// assert!(find("abc", "z") == -1);
/// ```
fn find(string hay, string needle) -> int
    ensures result >= -1 && result <= hay.len()
    ensures result < 0 || match_at(hay, needle, result)
    ensures needle.len() > 0 || result == 0
{
    return str_find_from(hay, needle, 0);
}

/// Returns the byte offset of the last `needle` in `hay`, or `-1`.
///
/// # Examples
///
/// ```
/// use text::{rfind};
/// # use tests::assert;
/// assert!(rfind("a=b=c", "=") == 3);
/// ```
fn rfind(string hay, string needle) -> int
    ensures result >= -1 && result <= hay.len()
    ensures result < 0 || match_at(hay, needle, result)
{
    return str_rfind(hay, needle);
}

/// Splits `s` at byte offset `at` into the part before and the part from `at` on.
///
/// # Errors
///
/// Returns `Err("utf8")` when `at` falls inside a multi-byte character.
///
/// # Examples
///
/// ```
/// use text::{split_at};
/// # use tests::assert;
/// let (a, b) = split_at("hello", 2) ?? ("", "");
/// assert!(a == "he" && b == "llo");
/// ```
fn split_at(string s, int at) -> Result<(string, string), string> {
    if at < 0 {
        at = 0;
    }
    if at > s.len() {
        at = s.len();
    }
    let left = sub(s, 0, at)?;
    let right = sub(s, at, s.len())?;
    return (left, right);
}

/// Splits `s` at every `sep`, returning the pieces between them.
///
/// Adjacent separators give empty pieces, and so does a separator at either end.
/// An empty `sep` returns `[s]`.
///
/// # Examples
///
/// ```
/// use text::{split};
/// # use tests::assert;
/// let parts = split("a,b,,c", ",") ?? Vec::new();
/// assert!(parts.len() == 4);
/// assert!(parts[2] == "");
/// ```
fn split(string s, string sep) -> Result<Vec<string>, string> {
    let out: Vec<string> = Vec::new();
    let nn = sep.len();
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
    let last = sub(s, start, s.len())?;
    out.push(last);
    return out;
}

/// Splits `s` at the first `sep` into the parts before and after it.
///
/// # Errors
///
/// Returns `Err` when `sep` does not occur in `s`.
///
/// # Examples
///
/// ```
/// use text::{split_once};
/// # use tests::assert;
/// let (k, v) = split_once("name=coil=lang", "=") ?? ("", "");
/// assert!(k == "name" && v == "coil=lang");
/// assert!(split_once("plain", "=").is_err());
/// ```
fn split_once(string s, string sep) -> Result<(string, string), string> {
    let at = str_find_from(s, sep, 0);
    if at < 0 {
        raise "separator not found";
    }
    let left = sub(s, 0, at)?;
    let right = sub(s, at + sep.len(), s.len())?;
    return (left, right);
}

/// Returns `s` with every non-overlapping `old` replaced by `new`, scanning left to right.
///
/// # Examples
///
/// ```
/// use text::{replace};
/// # use tests::assert;
/// assert!((replace("a-b-c", "-", ", ") ?? "") == "a, b, c");
/// ```
fn replace(string s, string old, string new) -> Result<string, string> {
    let nn = old.len();
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
    return out + sub(s, start, s.len())?;
}

/// Returns the `parts` concatenated with `sep` between each pair.
///
/// # Examples
///
/// ```
/// use text::{join};
/// # use tests::assert;
/// let parts: Vec<string> = ["usr", "local", "bin"];
/// assert!(join(parts, "/") == "usr/local/bin");
/// ```
fn join(Vec<string> parts, string sep) -> string
    ensures parts.len() > 0 || result == ""
    ensures parts.len() != 1 || result == parts[0]
{
    let out = "";
    let i = 0;
    while i < parts.len() {
        if i > 0 {
            out = out + sep;
        }
        out = out + parts[i];
        i = i + 1;
    }
    return out;
}

/// Returns `s` repeated `n` times; empty when `n <= 0`.
///
/// # Examples
///
/// ```
/// use text::{repeat};
/// # use tests::assert;
/// assert!(repeat("ab", 3) == "ababab");
/// ```
fn repeat(string s, int n) -> string
    ensures n > 0 || result == ""
    ensures n <= 0 || result.len() == s.len() * n
{
    let out = "";
    let i = 0;
    while i < n {
        out = out + s;
        i = i + 1;
    }
    return out;
}

/// Returns `s` with `fill` added in front until it is `width` bytes long. `fill` should be one byte; longer text is returned unchanged.
///
/// # Examples
///
/// ```
/// use text::{pad_left};
/// # use tests::assert;
/// assert!((pad_left("7", 3, "0") ?? "") == "007");
/// ```
fn pad_left(string s, int width, string fill) -> Result<string, string>
    ensures fill.len() != 1 || ok_len(result) == max_int(width, s.len())
    ensures fill.len() == 1 || ok_len(result) == -1
{
    if fill.len() != 1 {
        raise "fill must be one byte";
    }
    return repeat(fill, width - s.len()) + s;
}

/// Returns `s` with `fill` added at the end until it is `width` bytes long. `fill` should be one byte; longer text is returned unchanged.
///
/// # Examples
///
/// ```
/// use text::{pad_right};
/// # use tests::assert;
/// assert!((pad_right("ab", 4, ".") ?? "") == "ab..");
/// ```
fn pad_right(string s, int width, string fill) -> Result<string, string>
    ensures fill.len() != 1 || ok_len(result) == max_int(width, s.len())
    ensures fill.len() == 1 || ok_len(result) == -1
{
    if fill.len() != 1 {
        raise "fill must be one byte";
    }
    return s + repeat(fill, width - s.len());
}

fn line_piece(string s, int start, int end) -> Result<string, string> {
    if end > start && match_at(s, "\r", end - 1) {
        end = end - 1;
    }
    return sub(s, start, end)?;
}

/// Splits `s` into lines at each LF, dropping one CR before it (so CRLF works too).
///
/// # Examples
///
/// ```
/// use text::{lines};
/// # use tests::assert;
/// let ls = lines("one\r\ntwo\nthree") ?? Vec::new();
/// assert!(ls.len() == 3);
/// assert!(ls[0] == "one");
/// ```
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
    let last = line_piece(s, start, s.len())?;
    out.push(last);
    return out;
}

/// Returns `a` followed by `b`; the same as `a + b`.
fn concat(string a, string b) -> string
    ensures result.len() == a.len() + b.len()
{
    return a + b;
}

/// Returns `true` when `a` and `b` hold the same bytes; the same as `a == b`.
fn eq(string a, string b) -> bool {
    return a == b;
}

/// Returns `s` with ASCII `A`-`Z` turned into `a`-`z`; other characters are unchanged.
///
/// # Examples
///
/// ```
/// use text::{to_lower};
/// # use tests::assert;
/// assert!((to_lower("Hello, WORLD") ?? "") == "hello, world");
/// ```
fn to_lower(string s) -> Result<string, string>
    ensures ok_len(result) == s.len()
{
    let b = to_bytes(s);
    let out: Vec<byte> = Vec::new();
    let i = 0;
    let a_up: byte = "A";
    let z_up: byte = "Z";
    while i < b.len() {
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

/// Returns `s` with ASCII `a`-`z` turned into `A`-`Z`; other characters are unchanged.
///
/// # Examples
///
/// ```
/// use text::{to_upper};
/// # use tests::assert;
/// assert!((to_upper("coil") ?? "") == "COIL");
/// ```
fn to_upper(string s) -> Result<string, string>
    ensures ok_len(result) == s.len()
{
    let b = to_bytes(s);
    let out: Vec<byte> = Vec::new();
    let i = 0;
    let a_lo: byte = "a";
    let z_lo: byte = "z";
    while i < b.len() {
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
