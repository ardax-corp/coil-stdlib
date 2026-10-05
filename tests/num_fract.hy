use num::{trunc, fract, signum, lcm};

test("trunc toward zero negative") {
    let tn = trunc(0.0 - 3.9);
    assert(tn < 0.0)?;
    assert(tn > 0.0 - 4.1)?;
    assert(tn < 0.0 - 2.9)?;
}

test("fract soft") {
    let f = fract(3.25);
    assert(f > 0.24)?;
    assert(f < 0.26)?;
}

test("signum zero and neg") {
    assert(signum(0) == 0)?;
    assert(signum(0 - 3) == 0 - 1)?;
}

test("lcm zero operand") {
    assert(lcm(0, 5) == 0)?;
}
