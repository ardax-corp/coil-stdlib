use collections::map::{HashMap};

test("hashmap insert get update remove") {
    let m = HashMap::new();
    assert(m.insert(1, "a"))?;
    assert(m.insert(2, "b"))?;
    assert(m.insert(1, "A") == false)?;
    assert(m.size() == 2)?;
    assert(m.get(1, "?") == "A")?;
    assert(m.get(2, "?") == "b")?;
    assert(m.get(3, "?") == "?")?;
    assert(m.contains(2))?;
    assert(m.contains(9) == false)?;
    assert(m.remove(2))?;
    assert(m.contains(2) == false)?;
    assert(m.size() == 1)?;
    m.clear();
    assert(m.is_empty())?;
}

test("hashmap remove missing") {
    let m = HashMap::new();
    assert(m.remove(1) == false)?;
    assert(m.is_empty())?;
}

test("hashmap reinsert after remove") {
    let m = HashMap::new();
    assert(m.insert(1, 10))?;
    assert(m.remove(1))?;
    assert(m.insert(1, 20))?;
    assert(m.get(1, -1) == 20)?;
    assert(m.size() == 1)?;
}

test("hashmap clear then insert") {
    let m = HashMap::new();
    assert(m.insert(1, 10))?;
    m.clear();
    assert(m.is_empty())?;
    assert(m.insert(2, 30))?;
    assert(m.size() == 1)?;
    assert(m.get(2, -1) == 30)?;
    assert(m.contains(1) == false)?;
}

test("hashmap capacity power of two") {
    let m = HashMap::with_capacity(3);
    assert(m.capacity() == 8)?;
    let n = HashMap::with_capacity(16);
    assert(n.capacity() == 16)?;
}

test("hashmap single grow preserves entries") {
    let m = HashMap::new();
    assert(m.capacity() == 8)?;
    let i = 0;
    while i < 5 {
        assert(m.insert(i, i + 100))?;
        i = i + 1;
    }
    assert(m.capacity() == 16)?;
    assert(m.size() == 5)?;
    assert(m.get(0, -1) == 100)?;
    assert(m.get(4, -1) == 104)?;
    assert(m.contains(3))?;
    assert(m.contains(9) == false)?;
}

test("hashmap keys values") {
    let m = HashMap::new();
    assert(m.insert(1, 10))?;
    assert(m.insert(2, 20))?;
    let ks = m.keys();
    let vs = m.values();
    assert(len(ks) == 2)?;
    assert(len(vs) == 2)?;
}
