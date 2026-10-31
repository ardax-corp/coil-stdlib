use tests::assert;
use arith::{INT_MAX, INT_MIN, Checked, Wrapping, Saturating, Overflowing};

// `Some(v)` as `v`, `None` as `sentinel`.
fn or(Option<int> o, int sentinel) -> int {
    return match o {
        Option::Some(v) => v,
        Option::None => sentinel,
    };
}

fn none(Option<int> o) -> bool {
    return match o {
        Option::Some(_) => false,
        Option::None => true,
    };
}

fn neg(int x) -> int {
    return 0 - x;
}

test("checked add sub neg") {
    assert!(or(3.checked_add(4), 0) == 7);
    assert!(or((INT_MAX - 1).checked_add(1), 0) == INT_MAX);
    assert!(none(INT_MAX.checked_add(1)));
    assert!(none(INT_MIN.checked_add(neg(1))));
    assert!(or(INT_MIN.checked_add(INT_MAX), 0) == neg(1));
    assert!(or(3.checked_sub(4), 0) == neg(1));
    assert!(none(INT_MIN.checked_sub(1)));
    assert!(none(0.checked_sub(INT_MIN)));
    assert!(or(neg(1).checked_sub(INT_MIN), 0) == INT_MAX);
    assert!(or(5.checked_neg(), 0) == neg(5));
    assert!(none(INT_MIN.checked_neg()));
}

test("checked mul div rem") {
    assert!(or(6.checked_mul(7), 0) == 42);
    assert!(or(neg(4294967296).checked_mul(2147483648), 0) == INT_MIN);
    assert!(none(4294967296.checked_mul(2147483648)));
    assert!(none(INT_MAX.checked_mul(2)));
    assert!(none(INT_MIN.checked_mul(neg(1))));
    assert!(none(neg(1).checked_mul(INT_MIN)));
    assert!(or(INT_MIN.checked_mul(1), 0) == INT_MIN);
    assert!(or(INT_MAX.checked_mul(neg(1)), 0) == neg(INT_MAX));
    assert!(none(neg(3037000500).checked_mul(neg(3037000500))));
    assert!(or(neg(3037000499).checked_mul(neg(3037000499)), 0) == 9223372030926249001);
    assert!(or(0.checked_mul(INT_MIN), 1) == 0);
    assert!(or(neg(7).checked_div(2), 0) == neg(3));
    assert!(none(7.checked_div(0)));
    assert!(none(INT_MIN.checked_div(neg(1))));
    assert!(or(neg(7).checked_rem(2), 0) == neg(1));
    assert!(or(INT_MIN.checked_rem(neg(1)), 1) == 0);
    assert!(none(7.checked_rem(0)));
}

test("wrapping") {
    assert!(INT_MAX.wrapping_add(1) == INT_MIN);
    assert!(INT_MIN.wrapping_add(neg(1)) == INT_MAX);
    assert!(INT_MAX.wrapping_add(INT_MAX) == neg(2));
    assert!(INT_MIN.wrapping_add(INT_MIN) == 0);
    assert!(2.wrapping_add(3) == 5);
    assert!(INT_MIN.wrapping_sub(1) == INT_MAX);
    assert!(0.wrapping_sub(INT_MIN) == INT_MIN);
    assert!(neg(1).wrapping_sub(INT_MIN) == INT_MAX);
    assert!(INT_MIN.wrapping_neg() == INT_MIN);
    assert!(5.wrapping_neg() == neg(5));
}

test("wrapping mul") {
    assert!(3.wrapping_mul(7) == 21);
    assert!(INT_MAX.wrapping_mul(INT_MAX) == 1);
    assert!(INT_MIN.wrapping_mul(INT_MIN) == 0);
    assert!(INT_MAX.wrapping_mul(neg(2)) == 2);
    assert!(INT_MIN.wrapping_mul(neg(1)) == INT_MIN);
    assert!(123456789123.wrapping_mul(987654321987) == neg(346971251534834359));
    assert!(neg(123456789123).wrapping_mul(987654321987) == 346971251534834359);
    // Golden-ratio and FNV-1a multipliers, as a hash uses them.
    assert!(neg(7046029254386353131).wrapping_mul(31) == 2934021998537672331);
    assert!(1099511628211.wrapping_mul(neg(3750763034362895579)) == neg(5808590958014384161));
}

test("saturating") {
    assert!(INT_MAX.saturating_add(1) == INT_MAX);
    assert!(INT_MIN.saturating_add(neg(1)) == INT_MIN);
    assert!(2.saturating_add(3) == 5);
    assert!(INT_MIN.saturating_sub(1) == INT_MIN);
    assert!(0.saturating_sub(INT_MIN) == INT_MAX);
    assert!(INT_MAX.saturating_mul(2) == INT_MAX);
    assert!(INT_MAX.saturating_mul(neg(2)) == INT_MIN);
    assert!(INT_MIN.saturating_mul(neg(1)) == INT_MAX);
    assert!(neg(6).saturating_mul(7) == neg(42));
}

test("overflowing") {
    let (s, o) = INT_MAX.overflowing_add(1);
    assert!(s == INT_MIN && o);
    let (t, p) = 2.overflowing_add(3);
    assert!(t == 5 && !p);
    let (d, q) = INT_MIN.overflowing_sub(1);
    assert!(d == INT_MAX && q);
    let (m, r) = INT_MAX.overflowing_mul(INT_MAX);
    assert!(m == 1 && r);
    let (n, u) = INT_MIN.overflowing_neg();
    assert!(n == INT_MIN && u);
    let (k, v) = 4.overflowing_neg();
    assert!(k == neg(4) && !v);
}

test("checked pow") {
    assert!(or(2.checked_pow(10), 0) == 1024);
    assert!(or(3.checked_pow(0), 0) == 1);
    assert!(or(0.checked_pow(0), 0) == 1);
    assert!(or(0.checked_pow(5), 1) == 0);
    assert!(or(neg(3).checked_pow(3), 0) == neg(27));
    assert!(or(2.checked_pow(62), 0) == 4611686018427387904);
    assert!(none(2.checked_pow(63)));
    assert!(or(neg(2).checked_pow(63), 0) == INT_MIN);
    assert!(none(neg(2).checked_pow(64)));
    assert!(or(3.checked_pow(39), 0) == 4052555153018976267);
    assert!(none(3.checked_pow(40)));
    assert!(or(INT_MAX.checked_pow(1), 0) == INT_MAX);
    assert!(none(INT_MAX.checked_pow(2)));
    assert!(or(INT_MIN.checked_pow(1), 0) == INT_MIN);
    assert!(or(1.checked_pow(INT_MAX), 0) == 1);
    assert!(or(neg(1).checked_pow(INT_MAX), 0) == neg(1));
    assert!(or(neg(1).checked_pow(INT_MAX - 1), 0) == 1);
    assert!(none(2.checked_pow(neg(1))));
    assert!(none(1.checked_pow(neg(1))));
    assert!(none(0.checked_pow(INT_MIN)));
}

test("checked pow matches **") {
    let b = 0 - 7;
    while b <= 7 {
        let e = 0;
        while e <= 20 {
            assert!(or(b.checked_pow(e), 0) == b ** e);
            e = e + 1;
        }
        b = b + 1;
    }
}

test("wrapping pow") {
    assert!(2.wrapping_pow(10) == 1024);
    assert!(5.wrapping_pow(0) == 1);
    assert!(2.wrapping_pow(63) == INT_MIN);
    assert!(2.wrapping_pow(64) == 0);
    assert!(neg(2).wrapping_pow(63) == INT_MIN);
    assert!(3.wrapping_pow(40) == neg(6289078614652622815));
    assert!(INT_MAX.wrapping_pow(2) == 1);
    assert!(INT_MIN.wrapping_pow(2) == 0);
    assert!(neg(1).wrapping_pow(INT_MAX) == neg(1));
    assert!(1099511628211.wrapping_pow(3) == 624165263380053675);
    assert!(neg(7046029254386353131).wrapping_pow(5) == 3326886199428185477);
}

test("saturating pow") {
    assert!(2.saturating_pow(10) == 1024);
    assert!(2.saturating_pow(63) == INT_MAX);
    assert!(neg(2).saturating_pow(63) == INT_MIN);
    assert!(neg(2).saturating_pow(64) == INT_MAX);
    assert!(neg(3).saturating_pow(41) == INT_MIN);
    assert!(10.saturating_pow(INT_MAX) == INT_MAX);
    assert!(neg(1).saturating_pow(INT_MAX) == neg(1));
}

test("overflowing pow") {
    let (a, o) = 2.overflowing_pow(62);
    assert!(a == 4611686018427387904 && !o);
    let (b, p) = 2.overflowing_pow(63);
    assert!(b == INT_MIN && p);
    let (c, q) = neg(2).overflowing_pow(63);
    assert!(c == INT_MIN && !q);
    let (d, r) = 3.overflowing_pow(40);
    assert!(d == neg(6289078614652622815) && r);
    let (f, s) = 2.overflowing_pow(64);
    assert!(f == 0 && s);
    let (g, t) = 7.overflowing_pow(0);
    assert!(g == 1 && !t);
}

// A negative exponent panics with `negative exponent`, like `**`. Only
// `should_panic` doc examples can observe a panic, so these carry them.

/// ```should_panic
/// # use arith::Wrapping;
/// let e = 0 - 1;
/// let _ = 2.wrapping_pow(e);
/// ```
fn wrapping_pow_negative_panics() {}

/// ```should_panic
/// # use arith::Saturating;
/// let e = 0 - 1;
/// let _ = 2.saturating_pow(e);
/// ```
fn saturating_pow_negative_panics() {}

/// ```should_panic
/// # use arith::Overflowing;
/// let e = 0 - 1;
/// let _ = 2.overflowing_pow(e);
/// ```
fn overflowing_pow_negative_panics() {}

// Shift counts for #36: in range (`0..=63`), `64`, `-1` and large counts.
test("checked shl shr") {
    assert!(or(1.checked_shl(0), 0) == 1);
    assert!(or(1.checked_shl(4), 0) == 16);
    assert!(or(1.checked_shl(63), 0) == INT_MIN);
    assert!(or(neg(1).checked_shl(63), 0) == INT_MIN);
    assert!(or(3.checked_shl(62), 0) == INT_MIN + 4611686018427387904);
    assert!(none(1.checked_shl(64)));
    assert!(none(1.checked_shl(neg(1))));
    assert!(none(1.checked_shl(65)));
    assert!(none(1.checked_shl(1000)));
    assert!(none(1.checked_shl(INT_MAX)));
    assert!(none(1.checked_shl(INT_MIN)));
    assert!(none(0.checked_shl(64)));
    assert!(or(256.checked_shr(0), 0) == 256);
    assert!(or(256.checked_shr(4), 0) == 16);
    assert!(or(neg(1000).checked_shr(3), 0) == neg(125));
    assert!(or(INT_MIN.checked_shr(63), 0) == neg(1));
    assert!(or(INT_MAX.checked_shr(63), 1) == 0);
    assert!(none(256.checked_shr(64)));
    assert!(none(256.checked_shr(neg(1))));
    assert!(none(256.checked_shr(65)));
    assert!(none(256.checked_shr(1000)));
    assert!(none(256.checked_shr(INT_MAX)));
    assert!(none(256.checked_shr(INT_MIN)));
}

test("wrapping shl shr") {
    assert!(1.wrapping_shl(0) == 1);
    assert!(1.wrapping_shl(4) == 16);
    assert!(1.wrapping_shl(63) == INT_MIN);
    assert!(5.wrapping_shl(64) == 5);
    assert!(1.wrapping_shl(neg(1)) == INT_MIN);
    assert!(1.wrapping_shl(65) == 2);
    assert!(3.wrapping_shl(1000) == 3298534883328);
    assert!(1.wrapping_shl(INT_MAX) == INT_MIN);
    assert!(5.wrapping_shl(INT_MIN) == 5);
    assert!(256.wrapping_shr(4) == 16);
    assert!(neg(1000).wrapping_shr(3) == neg(125));
    assert!(INT_MIN.wrapping_shr(63) == neg(1));
    assert!(256.wrapping_shr(64) == 256);
    assert!(INT_MIN.wrapping_shr(neg(1)) == neg(1));
    assert!(INT_MAX.wrapping_shr(neg(1)) == 0);
    assert!(256.wrapping_shr(65) == 128);
    assert!(neg(1000).wrapping_shr(1027) == neg(125));
    assert!(INT_MIN.wrapping_shr(INT_MAX) == neg(1));
    assert!(256.wrapping_shr(INT_MIN) == 256);
}

test("overflowing shl shr") {
    let (a, o) = 1.overflowing_shl(4);
    assert!(a == 16 && !o);
    let (b, p) = 1.overflowing_shl(63);
    assert!(b == INT_MIN && !p);
    let (c, q) = 5.overflowing_shl(64);
    assert!(c == 5 && q);
    let (d, r) = 1.overflowing_shl(neg(1));
    assert!(d == INT_MIN && r);
    let (f, s) = 3.overflowing_shl(1000);
    assert!(f == 3298534883328 && s);
    let (g, t) = 5.overflowing_shl(INT_MIN);
    assert!(g == 5 && t);
    let (h, u) = neg(1000).overflowing_shr(3);
    assert!(h == neg(125) && !u);
    let (i, v) = INT_MIN.overflowing_shr(63);
    assert!(i == neg(1) && !v);
    let (j, w) = 256.overflowing_shr(64);
    assert!(j == 256 && w);
    let (k, x) = INT_MIN.overflowing_shr(neg(1));
    assert!(k == neg(1) && x);
    let (l, y) = 256.overflowing_shr(65);
    assert!(l == 128 && y);
    let (m, z) = INT_MIN.overflowing_shr(INT_MAX);
    assert!(m == neg(1) && z);
}
