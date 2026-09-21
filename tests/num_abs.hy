use num::{abs, min, max};

test("abs min max") {
    assert(abs(0 - 5) == 5)?;
    assert(abs(0) == 0)?;
    assert(abs(0.0 - 2.5) == 2.5)?;
    assert(abs(0.0) == 0.0)?;
    assert(min(3, 1) == 1)?;
    assert(max(3, 1) == 3)?;
    assert(min(3.0, 1.0) == 1.0)?;
    assert(max(3.0, 1.0) == 3.0)?;
}
