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
    assert(or(3.checked_add(4), 0) == 7)?;
    assert(or((INT_MAX - 1).checked_add(1), 0) == INT_MAX)?;
    assert(none(INT_MAX.checked_add(1)))?;
    assert(none(INT_MIN.checked_add(neg(1))))?;
    assert(or(INT_MIN.checked_add(INT_MAX), 0) == neg(1))?;
    assert(or(3.checked_sub(4), 0) == neg(1))?;
    assert(none(INT_MIN.checked_sub(1)))?;
    assert(none(0.checked_sub(INT_MIN)))?;
    assert(or(neg(1).checked_sub(INT_MIN), 0) == INT_MAX)?;
    assert(or(5.checked_neg(), 0) == neg(5))?;
    assert(none(INT_MIN.checked_neg()))?;
}

test("checked mul div rem") {
    assert(or(6.checked_mul(7), 0) == 42)?;
    assert(or(neg(4294967296).checked_mul(2147483648), 0) == INT_MIN)?;
    assert(none(4294967296.checked_mul(2147483648)))?;
    assert(none(INT_MAX.checked_mul(2)))?;
    assert(none(INT_MIN.checked_mul(neg(1))))?;
    assert(none(neg(1).checked_mul(INT_MIN)))?;
    assert(or(INT_MIN.checked_mul(1), 0) == INT_MIN)?;
    assert(or(INT_MAX.checked_mul(neg(1)), 0) == neg(INT_MAX))?;
    assert(none(neg(3037000500).checked_mul(neg(3037000500))))?;
    assert(or(neg(3037000499).checked_mul(neg(3037000499)), 0) == 9223372030926249001)?;
    assert(or(0.checked_mul(INT_MIN), 1) == 0)?;
    assert(or(neg(7).checked_div(2), 0) == neg(3))?;
    assert(none(7.checked_div(0)))?;
    assert(none(INT_MIN.checked_div(neg(1))))?;
    assert(or(neg(7).checked_rem(2), 0) == neg(1))?;
    assert(or(INT_MIN.checked_rem(neg(1)), 1) == 0)?;
    assert(none(7.checked_rem(0)))?;
}

test("wrapping") {
    assert(INT_MAX.wrapping_add(1) == INT_MIN)?;
    assert(INT_MIN.wrapping_add(neg(1)) == INT_MAX)?;
    assert(INT_MAX.wrapping_add(INT_MAX) == neg(2))?;
    assert(INT_MIN.wrapping_add(INT_MIN) == 0)?;
    assert(2.wrapping_add(3) == 5)?;
    assert(INT_MIN.wrapping_sub(1) == INT_MAX)?;
    assert(0.wrapping_sub(INT_MIN) == INT_MIN)?;
    assert(neg(1).wrapping_sub(INT_MIN) == INT_MAX)?;
    assert(INT_MIN.wrapping_neg() == INT_MIN)?;
    assert(5.wrapping_neg() == neg(5))?;
}

test("wrapping mul") {
    assert(3.wrapping_mul(7) == 21)?;
    assert(INT_MAX.wrapping_mul(INT_MAX) == 1)?;
    assert(INT_MIN.wrapping_mul(INT_MIN) == 0)?;
    assert(INT_MAX.wrapping_mul(neg(2)) == 2)?;
    assert(INT_MIN.wrapping_mul(neg(1)) == INT_MIN)?;
    assert(123456789123.wrapping_mul(987654321987) == neg(346971251534834359))?;
    assert(neg(123456789123).wrapping_mul(987654321987) == 346971251534834359)?;
    // Golden-ratio and FNV-1a multipliers, as a hash uses them.
    assert(neg(7046029254386353131).wrapping_mul(31) == 2934021998537672331)?;
    assert(1099511628211.wrapping_mul(neg(3750763034362895579)) == neg(5808590958014384161))?;
}

test("saturating") {
    assert(INT_MAX.saturating_add(1) == INT_MAX)?;
    assert(INT_MIN.saturating_add(neg(1)) == INT_MIN)?;
    assert(2.saturating_add(3) == 5)?;
    assert(INT_MIN.saturating_sub(1) == INT_MIN)?;
    assert(0.saturating_sub(INT_MIN) == INT_MAX)?;
    assert(INT_MAX.saturating_mul(2) == INT_MAX)?;
    assert(INT_MAX.saturating_mul(neg(2)) == INT_MIN)?;
    assert(INT_MIN.saturating_mul(neg(1)) == INT_MAX)?;
    assert(neg(6).saturating_mul(7) == neg(42))?;
}

test("overflowing") {
    let (s, o) = INT_MAX.overflowing_add(1);
    assert(s == INT_MIN && o)?;
    let (t, p) = 2.overflowing_add(3);
    assert(t == 5 && !p)?;
    let (d, q) = INT_MIN.overflowing_sub(1);
    assert(d == INT_MAX && q)?;
    let (m, r) = INT_MAX.overflowing_mul(INT_MAX);
    assert(m == 1 && r)?;
    let (n, u) = INT_MIN.overflowing_neg();
    assert(n == INT_MIN && u)?;
    let (k, v) = 4.overflowing_neg();
    assert(k == neg(4) && !v)?;
}
