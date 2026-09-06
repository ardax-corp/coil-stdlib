use num::{PI, E, TAU, abs, fract, is_nan, signum};

test("PI E TAU") {
    assert(PI > 3.14)?;
    assert(PI < 3.15)?;
    assert(E > 2.71)?;
    assert(E < 2.72)?;
    assert(TAU > 6.28)?;
    assert(TAU < 6.29)?;
    assert(TAU == PI * 2.0)?;
    assert(TAU / 2.0 == PI)?;
    let eps = 1.0 / 1000000.0;
    assert(abs(sin(PI / 2.0) - 1.0) < eps)?;
    assert(abs(exp(1.0) - E) < eps)?;
    assert(abs(cos(PI) + 1.0) < eps)?;
    assert(abs(cos(TAU) - 1.0) < eps)?;
    assert(abs(sin(0.0)) < eps)?;
    assert(abs(sin(TAU)) < eps)?;
    assert(abs(ln(E) - 1.0) < eps)?;
}

test("num fract signum nan") {
    let eps = 1.0 / 1000000.0;
    assert(abs(fract(3.25) - 0.25) < eps)?;
    assert(abs(fract(0.0 - 1.25) - (0.0 - 0.25)) < eps)?;
    assert(signum(0) == 0)?;
    assert(signum(0.0 - 4.0) == 0.0 - 1.0)?;
    assert(is_nan(PI) == false)?;
    assert(is_nan(E) == false)?;
}
