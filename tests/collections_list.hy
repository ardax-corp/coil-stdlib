use collections::list::{List};

test("list push pop front back") {
    let xs = List::new();
    assert(xs.is_empty())?;
    xs.push_front(1);
    xs.push_front(2);
    xs.push_back(3);
    assert(xs.size() == 3)?;
    assert((xs.peek_front() ?? 0) == 2)?;
    assert((xs.pop_front() ?? 0) == 2)?;
    assert((xs.pop_back() ?? 0) == 3)?;
    assert((xs.pop_front() ?? 0) == 1)?;
    assert((xs.pop_front() ?? -1) == -1)?;
    assert(xs.is_empty())?;
    xs.push_front(9);
    xs.clear();
    assert(xs.is_empty())?;
}

test("list to_vec") {
    let xs = List::new();
    xs.push_back(1);
    xs.push_back(2);
    xs.push_back(3);
    let v = xs.to_vec();
    assert(len(v) == 3)?;
    assert(v[0] == 1)?;
    assert(v[2] == 3)?;
}

test("list empty peek") {
    let xs = List::new();
    assert((xs.peek_front() ?? -7) == -7)?;
    assert((xs.pop_front() ?? -7) == -7)?;
    xs.push_front(5);
    assert(xs.size() == 1)?;
    assert((xs.peek_front() ?? 0) == 5)?;
}
