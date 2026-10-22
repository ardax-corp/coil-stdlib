// Scalar numeric helpers layered on auto-imported `prelude::math`.
// Named `num` so workspace `examples/src/math.hy` does not shadow this module.
//
// `abs` stays type-overloaded (numeric / negation, not Ord).
// `min` / `max` / `clamp` are generic over `Ord` (int, float, and derived orders).
// Powers are the `**` operator (`int` and `float`); checked/wrapping/saturating
// int powers are on the `arith` traits.
// IEEE scalars (`sin`/`atan`/`log10`/`sinh`/…) stay on `prelude::math`
// — auto-imported; this module does not re-export them.

// The circle constant π, as a `float`.
const PI = 3.141592653589793;

// Euler's number e, the base of `ln`, as a `float`.
const E = 2.718281828459045;

// A full turn τ = 2π, as a `float`.
const TAU = 6.283185307179586;

/// Returns the absolute value of `x`.
///
/// Panics with `integer overflow` for the smallest `int`, whose absolute value does not fit.
/// # Examples
///
/// ```
/// use num::{abs};
/// # use tests::assert;
/// assert!(abs(-5) == 5);
/// assert!(abs(2.5) == 2.5);
/// ```
fn abs(int x) -> int {
    if x < 0 {
        return 0 - x;
    }
    return x;
}

/// Returns the absolute value of `x`; `-0.0` becomes `0.0`.
fn abs(float x) -> float {
    if x > 0.0 {
        return x;
    }
    if x == 0.0 {
        return 0.0;
    }
    return 0.0 - x;
}

/// Returns the smaller of `a` and `b` (`a` when they are equal).
/// # Examples
///
/// ```
/// use num::{min};
/// # use tests::assert;
/// assert!(min(3, 7) == 3);
/// assert!(min("pear", "apple") == "apple");
/// ```
fn min<T: Ord>(T a, T b) -> T {
    if a < b {
        return a;
    }
    return b;
}

/// Returns the larger of `a` and `b` (`a` when they are equal).
/// # Examples
///
/// ```
/// use num::{max};
/// # use tests::assert;
/// assert!(max(3, 7) == 7);
/// ```
fn max<T: Ord>(T a, T b) -> T {
    if a > b {
        return a;
    }
    return b;
}

/// Rounds `x` to the nearest whole number; halves round away from zero.
/// # Examples
///
/// ```
/// use num::{round};
/// # use tests::assert;
/// assert!(round(2.5) == 3.0);
/// assert!(round(-2.5) == -3.0);
/// assert!(round(2.4) == 2.0);
/// ```
fn round(float x) -> float {
    if x >= 0.0 {
        return floor(x + 0.5);
    }
    return ceil(x - 0.5);
}

/// Returns `x` limited to the range `lo..=hi`.
/// # Examples
///
/// ```
/// use num::{clamp};
/// # use tests::assert;
/// assert!(clamp(15, 0, 10) == 10);
/// assert!(clamp(-3, 0, 10) == 0);
/// assert!(clamp(4, 0, 10) == 4);
/// ```
fn clamp<T: Ord>(T x, T lo, T hi) -> T {
    return min(max(x, lo), hi);
}

/// Returns `-1`, `0` or `1` by the sign of `x`.
/// # Examples
///
/// ```
/// use num::{signum};
/// # use tests::assert;
/// assert!(signum(-8) == -1);
/// assert!(signum(0) == 0);
/// ```
fn signum(int x) -> int {
    if x < 0 {
        return 0 - 1;
    }
    if x > 0 {
        return 1;
    }
    return 0;
}

/// Returns `-1.0`, `0.0` or `1.0` by the sign of `x`; a zero keeps its sign.
fn signum(float x) -> float {
    if x > 0.0 {
        return 1.0;
    }
    if x < 0.0 {
        return 0.0 - 1.0;
    }
    return 0.0;
}

/// Returns the greatest common divisor of `a` and `b`, which should be non-negative. `gcd(0, 0)` is `0`.
/// # Examples
///
/// ```
/// use num::{gcd};
/// # use tests::assert;
/// assert!(gcd(12, 18) == 6);
/// ```
fn gcd(int a, int b) -> int {
    if b == 0 {
        let x = a;
        if x < 0 {
            return 0 - x;
        }
        return x;
    }
    let r = a % b;
    return gcd(b, r);
}

/// Returns the least common multiple of `a` and `b`, which should be non-negative; `0` when either is `0`.
/// # Examples
///
/// ```
/// use num::{lcm};
/// # use tests::assert;
/// assert!(lcm(4, 6) == 12);
/// ```
fn lcm(int a, int b) -> int {
    if a == 0 {
        return 0;
    }
    if b == 0 {
        return 0;
    }
    let p = a * b;
    if p < 0 {
        p = 0 - p;
    }
    let g = gcd(a, b);
    return p / g;
}

/// Removes the fractional part of `x`, rounding toward zero.
/// # Examples
///
/// ```
/// use num::{trunc};
/// # use tests::assert;
/// assert!(trunc(-2.7) == -2.0);
/// ```
fn trunc(float x) -> float {
    if x >= 0.0 {
        return floor(x);
    }
    return ceil(x);
}

/// Returns the fractional part of `x`, `x - trunc(x)`; it has the sign of `x`.
fn fract(float x) -> float {
    return x - trunc(x);
}

/// Returns `true` when `x` is NaN (`0.0 / 0.0`, `sqrt(-1.0)`, …).
fn is_nan(float x) -> bool {
    return x != x;
}

/// Returns `true` when `x` is positive or negative infinity.
fn is_infinite(float x) -> bool {
    if is_nan(x) {
        return false;
    }
    let big = 1.0;
    let i = 0;
    while i < 400 {
        big = big * 10.0;
        i = i + 1;
    }
    return x == big || x == 0.0 - big;
}

/// Returns `true` when `x` is neither NaN nor infinite.
fn is_finite(float x) -> bool {
    return !is_nan(x) && !is_infinite(x);
}

/// Returns the remainder of `a / b` that is never negative: `0 <= r < abs(b)`.
///
/// Unlike `%`, whose result takes the sign of `a`. Panics with `division by zero` when `b` is `0`.
/// # Examples
///
/// ```
/// use num::{rem_euclid};
/// # use tests::assert;
/// assert!(rem_euclid(-7, 3) == 2);
/// assert!(-7 % 3 == -1);
/// ```
fn rem_euclid(int a, int b) -> int {
    let r = a % b;
    if r < 0 {
        return r + abs(b);
    }
    return r;
}

/// Returns the quotient that goes with `rem_euclid`: `a == div_euclid(a, b) * b + rem_euclid(a, b)`.
/// # Examples
///
/// ```
/// use num::{div_euclid};
/// # use tests::assert;
/// assert!(div_euclid(-7, 3) == -3);
/// ```
fn div_euclid(int a, int b) -> int {
    let r = rem_euclid(a, b);
    return (a - r) / b;
}

/// Returns `sqrt(a * a + b * b)`, the length of the hypotenuse.
/// # Examples
///
/// ```
/// use num::{hypot};
/// # use tests::assert;
/// assert!(hypot(3.0, 4.0) == 5.0);
/// ```
fn hypot(float a, float b) -> float {
    return sqrt(a * a + b * b);
}
