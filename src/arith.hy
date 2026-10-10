// Explicit int overflow behaviour. Plain `+ - *` and unary `-` panic on
// overflow (coil-lang#852); these traits say what to do instead:
//
// - `Checked`: `None` when the result does not fit.
// - `Wrapping`: the two's-complement result, modulo 2^64.
// - `Saturating`: clamped to `INT_MIN` / `INT_MAX`.
// - `Overflowing`: the wrapped result and whether it wrapped.
//
// All of it is plain Coil: every check runs before the operation, and no
// intermediate result overflows. Shifts and bit ops never trap.

// Largest `int`. (`///` would bind to a following `fn`.)
static const INT_MAX = 9223372036854775807;
// Smallest `int`.
static const INT_MIN = 0 - 9223372036854775807 - 1;

trait Checked<S> {
    /// `a + b`, or `None` when it does not fit.
    fn checked_add(S a, S b) -> Option<S> {}

    /// `a - b`, or `None` when it does not fit.
    fn checked_sub(S a, S b) -> Option<S> {}

    /// `a * b`, or `None` when it does not fit.
    fn checked_mul(S a, S b) -> Option<S> {}

    /// `a / b`, or `None` when `b` is zero or the quotient does not fit.
    fn checked_div(S a, S b) -> Option<S> {}

    /// `a % b`, or `None` when `b` is zero.
    fn checked_rem(S a, S b) -> Option<S> {}

    /// `-a`, or `None` when it does not fit.
    fn checked_neg(S a) -> Option<S> {}
}

trait Wrapping<S> {
    /// `a + b` modulo 2^64.
    fn wrapping_add(S a, S b) -> S {}

    /// `a - b` modulo 2^64.
    fn wrapping_sub(S a, S b) -> S {}

    /// `a * b` modulo 2^64.
    fn wrapping_mul(S a, S b) -> S {}

    /// `-a` modulo 2^64 (`INT_MIN` stays `INT_MIN`).
    fn wrapping_neg(S a) -> S {}
}

trait Saturating<S> {
    /// `a + b` clamped to the type's range.
    fn saturating_add(S a, S b) -> S {}

    /// `a - b` clamped to the type's range.
    fn saturating_sub(S a, S b) -> S {}

    /// `a * b` clamped to the type's range.
    fn saturating_mul(S a, S b) -> S {}
}

trait Overflowing<S> {
    /// The wrapped `a + b`, and whether it wrapped.
    fn overflowing_add(S a, S b) -> (S, bool) {}

    /// The wrapped `a - b`, and whether it wrapped.
    fn overflowing_sub(S a, S b) -> (S, bool) {}

    /// The wrapped `a * b`, and whether it wrapped.
    fn overflowing_mul(S a, S b) -> (S, bool) {}

    /// The wrapped `-a`, and whether it wrapped.
    fn overflowing_neg(S a) -> (S, bool) {}
}

fn add_fits(int a, int b) -> bool {
    if b > 0 {
        return a <= INT_MAX - b;
    }
    return a >= INT_MIN - b;
}

fn sub_fits(int a, int b) -> bool {
    if b < 0 {
        return a <= INT_MAX + b;
    }
    return a >= INT_MIN + b;
}

fn mul_fits(int a, int b) -> bool {
    if a == 0 || b == 0 {
        return true;
    }
    if a > 0 {
        if b > 0 {
            return a <= INT_MAX / b;
        }
        return b >= INT_MIN / a;
    }
    if b > 0 {
        return a >= INT_MIN / b;
    }
    return b >= INT_MAX / a;
}

// `a + b` when it overflows: both operands have its sign, so moving each
// by 2^63 toward zero first keeps every step in range.
fn add_wrapped(int a, int b) -> int {
    if b > 0 {
        return (a + INT_MIN) + (b + INT_MIN);
    }
    return (a - INT_MIN) + (b - INT_MIN);
}

fn wrap_add(int a, int b) -> int {
    if add_fits(a, b) {
        return a + b;
    }
    return add_wrapped(a, b);
}

fn wrap_neg(int a) -> int {
    if a == INT_MIN {
        return INT_MIN;
    }
    return 0 - a;
}

fn wrap_sub(int a, int b) -> int {
    // `-INT_MIN` wraps to `INT_MIN`, and `a - INT_MIN == a + INT_MIN` mod 2^64.
    return wrap_add(a, wrap_neg(b));
}

// The product modulo 2^64 from 32-bit halves `a = ah * 2^32 + al` (`al`
// unsigned, `ah` signed): `al * bl + (ah * bl + al * bh) * 2^32`. Each
// partial product fits; the left shifts drop exactly the bits past 2^64.
fn wrap_mul(int a, int b) -> int {
    if mul_fits(a, b) {
        return a * b;
    }
    let al = a & 4294967295;
    let ah = a >> 32;
    let bl = b & 4294967295;
    let bh = b >> 32;
    // `al * bl` can reach 2^64, so split `bl` once more into 16-bit halves.
    let lo = wrap_add((al * (bl >> 16)) << 16, al * (bl & 65535));
    let mid = wrap_add(ah * bl, al * bh) << 32;
    return wrap_add(lo, mid);
}

impl Checked for int {
    pub fn checked_add(int a, int b) -> Option<int> {
        if add_fits(a, b) {
            return Some(a + b);
        }
        return None;
    }

    pub fn checked_sub(int a, int b) -> Option<int> {
        if sub_fits(a, b) {
            return Some(a - b);
        }
        return None;
    }

    pub fn checked_mul(int a, int b) -> Option<int> {
        if mul_fits(a, b) {
            return Some(a * b);
        }
        return None;
    }

    pub fn checked_div(int a, int b) -> Option<int> {
        if b == 0 {
            return None;
        }
        if a == INT_MIN && b == 0 - 1 {
            return None;
        }
        return Some(a / b);
    }

    pub fn checked_rem(int a, int b) -> Option<int> {
        if b == 0 {
            return None;
        }
        return Some(a % b);
    }

    pub fn checked_neg(int a) -> Option<int> {
        if a == INT_MIN {
            return None;
        }
        return Some(0 - a);
    }
}

impl Wrapping for int {
    pub fn wrapping_add(int a, int b) -> int {
        return wrap_add(a, b);
    }

    pub fn wrapping_sub(int a, int b) -> int {
        return wrap_sub(a, b);
    }

    pub fn wrapping_mul(int a, int b) -> int {
        return wrap_mul(a, b);
    }

    pub fn wrapping_neg(int a) -> int {
        return wrap_neg(a);
    }
}

impl Saturating for int {
    pub fn saturating_add(int a, int b) -> int {
        if add_fits(a, b) {
            return a + b;
        }
        if b > 0 {
            return INT_MAX;
        }
        return INT_MIN;
    }

    pub fn saturating_sub(int a, int b) -> int {
        if sub_fits(a, b) {
            return a - b;
        }
        if b < 0 {
            return INT_MAX;
        }
        return INT_MIN;
    }

    pub fn saturating_mul(int a, int b) -> int {
        if mul_fits(a, b) {
            return a * b;
        }
        if (a < 0) == (b < 0) {
            return INT_MAX;
        }
        return INT_MIN;
    }
}

impl Overflowing for int {
    pub fn overflowing_add(int a, int b) -> (int, bool) {
        return (wrap_add(a, b), !add_fits(a, b));
    }

    pub fn overflowing_sub(int a, int b) -> (int, bool) {
        return (wrap_sub(a, b), !sub_fits(a, b));
    }

    pub fn overflowing_mul(int a, int b) -> (int, bool) {
        return (wrap_mul(a, b), !mul_fits(a, b));
    }

    pub fn overflowing_neg(int a) -> (int, bool) {
        return (wrap_neg(a), a == INT_MIN);
    }
}
