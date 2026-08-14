use collections::set::{HashSet};

test("hashset insert contains remove") {
    let s = HashSet::new();
    assert(s.insert(1))?;
    assert(s.insert(2))?;
    assert(s.insert(1) == false)?;
    assert(s.size() == 2)?;
    assert(s.contains(1))?;
    assert(s.contains(3) == false)?;
    assert(s.remove(1))?;
    assert(s.contains(1) == false)?;
    assert(s.size() == 1)?;
    s.clear();
    assert(s.is_empty())?;
}

test("hashset remove missing and reuse") {
    let s = HashSet::new();
    assert(s.remove(9) == false)?;
    assert(s.insert(5))?;
    assert(s.remove(5))?;
    assert(s.insert(5))?;
    assert(s.contains(5))?;
}
