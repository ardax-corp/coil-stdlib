use collections::tree::{TreeMap};

test("treemap insert update") {
    let t = TreeMap::new();
    assert(t.insert(2, 20) == true)?;
    assert(t.insert(1, 10) == true)?;
    assert(t.insert(3, 30) == true)?;
    assert(t.insert(2, 22) == false)?;
    assert(t.size() == 3)?;
}

test("treemap get contains") {
    let t = TreeMap::new();
    assert(t.insert(2, 20))?;
    assert(t.insert(1, 10))?;
    assert(t.insert(3, 30))?;
    assert(t.insert(2, 22) == false)?;
    assert(t.get(1, -1) == 10)?;
    assert(t.get(2, -1) == 22)?;
    assert(t.get(3, -1) == 30)?;
    assert(t.contains(3) == true)?;
    assert(t.contains(9) == false)?;
}

test("treemap empty and skewed inserts") {
    let t = TreeMap::empty();
    assert(t.is_empty())?;
    assert(t.size() == 0)?;
    assert(t.contains(1) == false)?;
    assert(t.get(1, -1) == -1)?;
    assert(t.insert(1, 10))?;
    assert(t.insert(2, 20))?;
    assert(t.insert(3, 30))?;
    assert(t.insert(4, 40))?;
    assert(t.size() == 4)?;
    assert(t.get(1, -1) == 10)?;
    assert(t.get(4, -1) == 40)?;
    assert(t.contains(2))?;
    assert(t.contains(9) == false)?;
}

test("treemap left spine inserts") {
    let t = TreeMap::new();
    assert(t.insert(4, 40))?;
    assert(t.insert(3, 30))?;
    assert(t.insert(2, 20))?;
    assert(t.insert(1, 10))?;
    assert(t.size() == 4)?;
    assert(t.get(1, -1) == 10)?;
    assert(t.get(4, -1) == 40)?;
    assert(t.contains(2))?;
}

test("treemap remove clear min max") {
    let t = TreeMap::new();
    assert(t.insert(2, 20))?;
    assert(t.insert(1, 10))?;
    assert(t.insert(3, 30))?;
    let mk = t.min_key(0);
    assert(mk == 1)?;
    let xk = t.max_key(0);
    assert(xk == 3)?;
    assert(t.remove(2))?;
    assert(t.contains(2) == false)?;
    assert(t.get(2, -1) == -1)?;
    t.clear();
    assert(t.is_empty())?;
}

test("treemap remove non-root leaves") {
    let t = TreeMap::new();
    assert(t.insert(10, 100))?;
    assert(t.insert(5, 50))?;
    assert(t.insert(15, 150))?;
    assert(t.insert(12, 120))?;
    assert(t.remove(12))?;
    assert(t.contains(12) == false)?;
    assert(t.contains(15))?;
    assert(t.contains(5))?;
    assert(t.size() == 3)?;
    assert(t.remove(5))?;
    assert(t.contains(5) == false)?;
    assert(t.get(10, -1) == 100)?;
    assert(t.size() == 2)?;
    assert(t.remove(99) == false)?;
}

test("treemap remove two-child node") {
    let t = TreeMap::new();
    assert(t.insert(2, 20))?;
    assert(t.insert(1, 10))?;
    assert(t.insert(3, 30))?;
    assert(t.remove(2))?;
    assert(t.contains(2) == false)?;
    assert(t.contains(1))?;
    assert(t.contains(3))?;
    assert(t.size() == 2)?;
    assert(t.min_key(0) == 1)?;
    assert(t.max_key(0) == 3)?;
}

test("treemap empty min max") {
    let t = TreeMap::new();
    assert(t.min_key(0 - 1) == 0 - 1)?;
    assert(t.max_key(0 - 1) == 0 - 1)?;
}
