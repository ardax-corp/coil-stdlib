// String helpers on byte offsets (userland).
// Byte-oriented offsets — slicing mid-codepoint yields UTF-8 errors.
// Named `text` because virtual `string` already owns `format` / `to_bytes` / `from_bytes`.
// Search is plain loops over `s[i]`, which reads the string in place; the
// compiler runs the no-match stretches 64 bytes at a time
// (coil-lang `docs/internals/byte-simd.md`).
use string::{to_bytes, from_bytes, slice_bytes};
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
    return is_space(s[i]);
}

// `needle` at byte offset `at` of `s`.
fn match_at(string s, string needle, int at) -> bool {
    let m = needle.len();
    if at < 0 || at > s.len() - m {
        return false;
    }
    let j = 0;
    while j < m && s[at + j] == needle[j] {
        j = j + 1;
    }
    return j == m;
}

// Byte offset of the first `needle` in `hay` at or after `from` (clamped
// to `0 ..= hay.len()`), or `-1`. An empty needle matches at `from`.
// Candidates are filtered on the needle's first two bytes.
fn find_at(string hay, string needle, int from) -> int {
    let n = hay.len();
    let m = needle.len();
    let i = from;
    if i < 0 {
        i = 0;
    }
    if i > n {
        i = n;
    }
    if m == 0 {
        return i;
    }
    let last = n - m;
    let first = needle[0];
    if m == 1 {
        while i <= last {
            if hay[i] == first {
                return i;
            }
            i = i + 1;
        }
        return -1;
    }
    // A candidate needs the needle's first and last bytes; checking both
    // skips the false starts a common first pair (or prefix) leaves.
    let k = m - 1;
    let tail = needle[k];
    while i <= last {
        if hay[i] == first && hay[i + k] == tail {
            let j = 1;
            while j < k && hay[i + j] == needle[j] {
                j = j + 1;
            }
            if j >= k {
                return i;
            }
        }
        i = i + 1;
    }
    return -1;
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
    let m = needle.len();
    let i = hay.len() - m;
    while i >= 0 {
        if match_at(hay, needle, i) {
            return i;
        }
        i = i - 1;
    }
    return -1;
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
/// A final LF ends the last line rather than starting an empty one, so
/// `"a\nb\n"` and `"a\nb"` both give two lines, and `""` gives none.
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
    let at = find_at(s, "\n", 0);
    while at >= 0 {
        let piece = line_piece(s, start, at)?;
        out.push(piece);
        start = at + 1;
        at = find_at(s, "\n", start);
    }
    // A final LF ends the last line; it does not start an empty one.
    if start < s.len() {
        out.push(line_piece(s, start, s.len())?);
    }
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

// Byte offset of the character after the one starting at `i`, so a search
// that steps over an empty match never lands inside a UTF-8 sequence.
fn next_char(string s, int i) -> int {
    let n = s.len();
    let j = i + 1;
    while j < n && s[j] as int >= 128 && s[j] as int < 192 {
        j = j + 1;
    }
    return j;
}

// Byte slice at offsets a `Pattern` reported; those sit on character
// boundaries, so a decode error is a broken `Pattern` instance.
fn span_text(string s, int start, int end) -> string {
    return match slice_bytes(s, start, end) {
        Result::Ok(x) => x,
        Result::Err(_) => panic "text: pattern span splits a character",
    };
}

/// A match: the byte offsets `start..end` of the matched text.
#[derive(Show, Eq)]
class Span {
    pub start: int,
    pub end: int,
}

/// Something a [`Searchable`] value can be searched for: a plain `string`
/// (matched literally), or a type such as coil-regex's `Regex`.
///
/// Spans are byte offsets into the searched string, on
/// character boundaries. Searching from `from` finds the leftmost match that
/// starts at or after `from`.
///
/// # Examples
///
/// ```
/// use text::{Pattern, Span};
/// # use tests::assert;
/// let at = "-".find_in("a-b-c", 2) ?? new Span(0, 0);
/// assert!(at.start == 3 && at.end == 4);
/// ```
trait Pattern<P> {
    /// Returns the span of the leftmost match in `hay` at or after byte `from`.
    fn find_in(P pat, string hay, int from) -> Option<Span> {}

    /// Returns `true` when a match starts at the beginning of `hay`.
    fn is_prefix_of(P pat, string hay) -> bool {}

    /// Returns `true` when a match ends at the end of `hay`.
    fn is_suffix_of(P pat, string hay) -> bool {}

    /// Returns the replacement text for the match `find_in` just returned.
    ///
    /// The default is `template` itself. A regex substitutes its captures
    /// (`$1`, `${name}`).
    fn expand(P pat, string template) -> string {
        return template;
    }
}

impl Pattern for string {
    pub fn find_in(string pat, string hay, int from) -> Option<Span> {
        let at = find_at(hay, pat, from);
        if at < 0 {
            return Option::None;
        }
        return Option::Some(new Span(at, at + pat.len()));
    }

    pub fn is_prefix_of(string pat, string hay) -> bool {
        return match_at(hay, pat, 0);
    }

    pub fn is_suffix_of(string pat, string hay) -> bool {
        return match_at(hay, pat, hay.len() - pat.len());
    }

    pub fn expand(string pat, string template) -> string {
        return template;
    }
}

/// Pattern search methods (`contains`, `find`, `split`, `replace_all`, …) on
/// any [`Show`] type, which search its display form. `string` has them built
/// in, so `"foobar".contains("oba")` works with a `string` or any other
/// [`Pattern`] (such as a compiled `Regex`).
///
/// Give your own type the methods with an empty instance; they search
/// `value.show()`:
///
/// ```
/// use text::{Searchable};
/// # use tests::assert;
///
/// class Version {
///     pub major: int,
///     pub minor: int,
/// }
///
/// impl Show for Version {
///     pub fn show(Version v) -> string {
///         return string::format("%i.%i", v.major, v.minor);
///     }
/// }
///
/// impl Searchable for Version {}
///
/// fn main() {
///     assert!(new Version(1, 12).starts_with("1."));
/// }
/// ```
///
/// Empty matches step over one character, so an empty pattern matches
/// between every pair of characters (`"ab".split("")` is `["", "a", "b", ""]`).
///
/// # Examples
///
/// ```
/// use text::{Searchable};
/// # use tests::assert;
/// assert!("foobar".contains("oba"));
/// assert!("a,b,,c".split(",").len() == 4);
/// assert!("a-b-c".replace_all("-", "+") == "a+b+c");
/// ```
trait Searchable<T: Show> {
    /// Returns `true` when `pat` matches anywhere in `hay`.
    fn contains<P: Pattern>(T hay, P pat) -> bool {
        return pat.find_in(hay.show(), 0).is_some();
    }

    /// Returns `true` when a match of `pat` starts at the beginning of `hay`.
    fn starts_with<P: Pattern>(T hay, P pat) -> bool {
        return pat.is_prefix_of(hay.show());
    }

    /// Returns `true` when a match of `pat` ends at the end of `hay`.
    fn ends_with<P: Pattern>(T hay, P pat) -> bool {
        return pat.is_suffix_of(hay.show());
    }

    /// Returns the byte span of the first match of `pat`, or `None`.
    fn find<P: Pattern>(T hay, P pat) -> Option<Span> {
        return pat.find_in(hay.show(), 0);
    }

    /// Returns the byte spans of every non-overlapping match, left to right.
    fn find_all<P: Pattern>(T hay, P pat) -> Vec<Span> {
        let s = hay.show();
        let out: Vec<Span> = Vec::new();
        let from = 0;
        while from <= s.len() {
            let span = pat.find_in(s, from) ?? new Span(-1, -1);
            if span.start < 0 {
                break;
            }
            let start = span.start;
            let end = span.end;
            out.push(span);
            from = end;
            if end == start {
                from = next_char(s, end);
            }
        }
        return out;
    }

    /// Returns the pieces of `hay` between the matches of `pat`.
    ///
    /// A match at either end gives an empty first or last piece.
    fn split<P: Pattern>(T hay, P pat) -> Vec<string> {
        let s = hay.show();
        let out: Vec<string> = Vec::new();
        let piece = 0;
        let from = 0;
        while from <= s.len() {
            let span = pat.find_in(s, from) ?? new Span(-1, -1);
            if span.start < 0 {
                break;
            }
            let start = span.start;
            let end = span.end;
            out.push(span_text(s, piece, start));
            piece = end;
            from = end;
            if end == start {
                from = next_char(s, end);
            }
        }
        out.push(span_text(s, piece, s.len()));
        return out;
    }

    /// Splits `hay` at the first match of `pat` into the parts before and after it.
    fn split_once<P: Pattern>(T hay, P pat) -> Option<(string, string)> {
        let s = hay.show();
        let span = match pat.find_in(s, 0) {
            Option::Some(found) => found,
            Option::None => {
                return Option::None;
            },
        };
        return Option::Some((span_text(s, 0, span.start), span_text(s, span.end, s.len())));
    }

    /// Returns `hay` with its first match of `pat` replaced by `with`.
    ///
    /// A regex pattern expands `$1` / `${name}` in `with`.
    fn replace_first<P: Pattern>(T hay, P pat, string with) -> string {
        let s = hay.show();
        let span = match pat.find_in(s, 0) {
            Option::Some(found) => found,
            Option::None => {
                return s;
            },
        };
        return span_text(s, 0, span.start) + pat.expand(with) + span_text(s, span.end, s.len());
    }

    /// Returns `hay` with every non-overlapping match of `pat` replaced by `with`.
    ///
    /// A regex pattern expands `$1` / `${name}` in `with`.
    fn replace_all<P: Pattern>(T hay, P pat, string with) -> string {
        let s = hay.show();
        let out = "";
        let piece = 0;
        let from = 0;
        while from <= s.len() {
            let span = pat.find_in(s, from) ?? new Span(-1, -1);
            if span.start < 0 {
                break;
            }
            let start = span.start;
            let end = span.end;
            out = out + span_text(s, piece, start) + pat.expand(with);
            piece = end;
            from = end;
            if end == start {
                from = next_char(s, end);
            }
        }
        return out + span_text(s, piece, s.len());
    }
}

impl Searchable for string {
}
