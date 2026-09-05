use num::{PI, E, TAU, abs};

test("PI E TAU") {
    assert(PI > 3.14)?;
    assert(PI < 3.15)?;
    assert(E > 2.71)?;
    assert(E < 2.72)?;
    assert(TAU > 6.28)?;
    assert(TAU < 6.29)?;
    assert(TAU == PI * 2.0)?;
    let eps = 1.0 / 1000000.0;
    assert(abs(sin(PI / 2.0) - 1.0) < eps)?;
    assert(abs(exp(1.0) - E) < eps)?;
}
