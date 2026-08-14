// Shared decimal parsing and formatting helpers (pure userland).
use string::{to_bytes, from_bytes};
use ascii::{is_digit, digit_val, digit_char, is_space, hex_digit, hex_val};
use bytes::{slice as bytes_slice};

fn trim_ascii(string s) -> string {
    let b = to_bytes(s);
    let lo = 0;
    let hi = len(b);
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

/// Format an integer in base 10.
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

/// Format an integer in base 16 (lowercase, no prefix).
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

/// Format an integer in base 2 (no prefix).
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

/// Parse an optionally signed integer in base `radix` (10 or 16).
fn parse_int_radix(string s, int radix) -> Result<int, string> {
    let trimmed = trim_ascii(s);
    let b = to_bytes(trimmed);
    if len(b) == 0 {
        raise "invalid integer";
    }
    let i = 0;
    let negative = false;
    if b[i] == "-" || b[i] == "+" {
        negative = b[i] == "-";
        i = i + 1;
    }
    if i >= len(b) {
        raise "invalid integer";
    }
    let value = 0;
    while i < len(b) {
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

/// Parse an optionally signed base-10 integer (surrounding ASCII space skipped).
fn parse_int(string s) -> Result<int, string> {
    return parse_int_radix(s, 10)?;
}

/// Parse an optionally signed decimal float with an optional exponent.
fn parse_float(string s) -> Result<float, string> {
    let b = to_bytes(trim_ascii(s));
    if len(b) == 0 {
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
    if i >= len(b) {
        raise "invalid float";
    }

    let value = 0.0;
    let saw_digit = false;
    while i < len(b) {
        if is_digit(b[i]) == false {
            break;
        }
        let whole_digit = digit_val(b[i]);
        value = value * 10.0 + (whole_digit as float);
        saw_digit = true;
        i = i + 1;
    }

    let frac_places: int = 0;
    if i < len(b) {
        if b[i] == "." {
            i = i + 1;
            while i < len(b) {
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
    if i < len(b) {
        if b[i] == "e" || b[i] == "E" {
            i = i + 1;
            if i < len(b) {
                if b[i] == "-" || b[i] == "+" {
                    divide_exp = b[i] == "-";
                    i = i + 1;
                }
            }
            let exponent_start = i;
            while i < len(b) {
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
    if i != len(b) {
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
