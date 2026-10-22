// Shared decimal parsing and formatting helpers (pure userland).
use string::{to_bytes, from_bytes};
use ascii::{is_digit, digit_val, digit_char, is_space, hex_digit, hex_val};
use bytes::slice as bytes_slice;

fn trim_ascii(string s) -> string {
    let b = to_bytes(s);
    let lo = 0;
    let hi = b.len();
    while lo < hi {
        if is_space(b[lo]) {
            lo = lo + 1;
        } else {
            break;
        }
    }
    while hi > lo {
        if is_space(b[hi - 1]) {
            hi = hi - 1;
        } else {
            break;
        }
    }
    return match from_bytes(bytes_slice(b, lo, hi)) {
        Result::Ok(x) => x,
        Result::Err(_) => "",
    };
}

fn hex_nibble_char(int n) -> string {
    let b = hex_digit(n);
    let v: Vec<byte> = Vec::new();
    v.push(b);
    return match from_bytes(v) {
        Result::Ok(s) => s,
        Result::Err(_) => "",
    };
}

/// Formats `n` in decimal; the same as `format("%i", n)`.
/// # Examples
///
/// ```
/// use conv::{int_to_dec};
/// # use tests::assert;
/// assert!(int_to_dec(-42) == "-42");
/// ```
fn int_to_dec(int n) -> string {
    if n == 0 {
        return "0";
    }
    let negative = n < 0;
    let x = n;
    if x > 0 {
        x = 0 - x;
    }
    let out = "";
    while x < 0 {
        let digit = 0 - (x % 10);
        out = digit_char(digit) + out;
        x = x / 10;
    }
    if negative {
        return "-" + out;
    }
    return out;
}

/// Formats `n` in lowercase hexadecimal without a prefix; a negative `n` gets a leading `-`.
/// # Examples
///
/// ```
/// use conv::{int_to_hex};
/// # use tests::assert;
/// assert!(int_to_hex(255) == "ff");
/// ```
fn int_to_hex(int n) -> string {
    if n == 0 {
        return "0";
    }
    let negative = n < 0;
    let x = n;
    if x > 0 {
        x = 0 - x;
    }
    let out = "";
    while x < 0 {
        let digit = 0 - (x % 16);
        out = hex_nibble_char(digit) + out;
        x = x / 16;
    }
    if negative {
        return "-" + out;
    }
    return out;
}

/// Formats `n` in binary without a prefix; a negative `n` gets a leading `-`.
/// # Examples
///
/// ```
/// use conv::{int_to_bin};
/// # use tests::assert;
/// assert!(int_to_bin(5) == "101");
/// ```
fn int_to_bin(int n) -> string {
    if n == 0 {
        return "0";
    }
    let negative = n < 0;
    let x = n;
    if x > 0 {
        x = 0 - x;
    }
    let out = "";
    while x < 0 {
        let bit = 0 - (x % 2);
        out = digit_char(bit) + out;
        x = x / 2;
    }
    if negative {
        return "-" + out;
    }
    return out;
}

/// Parses an integer written in base `radix`, which must be 10 or 16.
///
/// Surrounding ASCII whitespace and one leading `+` or `-` are accepted. Hex
/// digits may be either case; there is no `0x` prefix.
///
/// # Errors
///
/// `Err("invalid integer")` for empty or non-digit text and `Err("invalid radix")`
/// for any other `radix`. A value that does not fit in an `int` currently panics
/// instead of returning an error (coil-stdlib#53).
/// # Examples
///
/// ```
/// use conv::{parse_int_radix};
/// # use tests::assert;
/// assert!((parse_int_radix("ff", 16) ?? 0) == 255);
/// assert!((parse_int_radix("-10", 10) ?? 0) == -10);
/// assert!(parse_int_radix("12", 8).is_err());
/// ```
fn parse_int_radix(string s, int radix) -> Result<int, string> {
    let trimmed = trim_ascii(s);
    let b = to_bytes(trimmed);
    if b.len() == 0 {
        raise "invalid integer";
    }
    let i = 0;
    let negative = false;
    if b[i] == "-" || b[i] == "+" {
        negative = b[i] == "-";
        i = i + 1;
    }
    if i >= b.len() {
        raise "invalid integer";
    }
    let value = 0;
    while i < b.len() {
        let digit = -1;
        if radix == 10 {
            digit = digit_val(b[i]);
        } else {
            if radix == 16 {
                digit = hex_val(b[i]);
            } else {
                raise "invalid radix";
            }
        }
        if digit < 0 {
            raise "invalid integer";
        }
        let next = value * radix + digit;
        if next < value {
            raise "overflow";
        }
        value = next;
        i = i + 1;
    }
    if negative {
        return 0 - value;
    }
    return value;
}

/// Parses a decimal integer, such as `"42"`, `" -7 "` or `"+3"`.
///
/// # Errors
///
/// `Err("invalid integer")` when `s` is empty or has a character that is not a
/// digit. See `parse_int_radix` for the overflow caveat.
/// # Examples
///
/// ```
/// use conv::{parse_int};
/// # use tests::assert;
/// assert!((parse_int(" 42 ") ?? 0) == 42);
/// let bad = match parse_int("4x2") {
///     Result::Err(e) => e,
///     Result::Ok(_) => "",
/// };
/// assert!(bad == "invalid integer");
/// ```
fn parse_int(string s) -> Result<int, string> {
    return parse_int_radix(s, 10)?;
}

/// Parses a decimal float such as `"3.5"`, `"-0.25"`, `"1e3"` or `"42"`.
///
/// Surrounding ASCII whitespace, a sign and an exponent (`e` or `E`) are accepted.
///
/// # Errors
///
/// `Err("invalid float")` when `s` is not a number.
/// # Examples
///
/// ```
/// use conv::{parse_float};
/// # use tests::assert;
/// assert!((parse_float("2.5") ?? 0.0) == 2.5);
/// assert!((parse_float("1e3") ?? 0.0) == 1000.0);
/// assert!(parse_float("abc").is_err());
/// ```
fn parse_float(string s) -> Result<float, string> {
    let b = to_bytes(trim_ascii(s));
    if b.len() == 0 {
        raise "invalid float";
    }

    let i = 0;
    let sign = 1.0;
    if b[i] == "-" || b[i] == "+" {
        if b[i] == "-" {
            sign = 0.0 - 1.0;
        }
        i = i + 1;
    }
    if i >= b.len() {
        raise "invalid float";
    }

    let value = 0.0;
    let saw_digit = false;
    while i < b.len() {
        if is_digit(b[i]) == false {
            break;
        }
        let whole_digit = digit_val(b[i]);
        value = value * 10.0 + (whole_digit as float);
        saw_digit = true;
        i = i + 1;
    }

    let frac_places: int = 0;
    if i < b.len() {
        if b[i] == "." {
            i = i + 1;
            while i < b.len() {
                if is_digit(b[i]) == false {
                    break;
                }
                let fraction_digit = digit_val(b[i]);
                value = value * 10.0 + (fraction_digit as float);
                frac_places = frac_places + 1;
                saw_digit = true;
                i = i + 1;
            }
        }
    }
    if !saw_digit {
        raise "invalid float";
    }

    let p: int = 0;
    while p < frac_places {
        value = value / 10.0;
        p = p + 1;
    }

    let exponent: int = 0;
    let divide_exp = false;
    if i < b.len() {
        if b[i] == "e" || b[i] == "E" {
            i = i + 1;
            if i < b.len() {
                if b[i] == "-" || b[i] == "+" {
                    divide_exp = b[i] == "-";
                    i = i + 1;
                }
            }
            let exponent_start = i;
            while i < b.len() {
                if is_digit(b[i]) == false {
                    break;
                }
                let exponent_digit: int = digit_val(b[i]);
                exponent = exponent * 10 + exponent_digit;
                i = i + 1;
            }
            if i == exponent_start {
                raise "invalid float";
            }
        }
    }
    if i != b.len() {
        raise "invalid float";
    }

    let scaled = sign * value;
    let e: int = 0;
    while e < exponent {
        if divide_exp {
            scaled = scaled / 10.0;
        } else {
            scaled = scaled * 10.0;
        }
        e = e + 1;
    }
    return scaled;
}
