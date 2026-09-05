use collections::bitset::{BitSet, bits_per_word};

test("bitset insert contains remove") {
    let s = BitSet::new();
    assert(s.is_empty())?;
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

test("bitset remove missing and reuse") {
    let s = BitSet::new();
    assert(s.remove(9) == false)?;
    assert(s.insert(5))?;
    assert(s.remove(5))?;
    assert(s.insert(5))?;
    assert(s.contains(5))?;
    assert(s.size() == 1)?;
}

test("bitset grow across words") {
    let w = bits_per_word();
    assert(w == 63)?;
    let s = BitSet::new();
    assert(s.capacity() == 0)?;
    assert(s.insert(0))?;
    assert(s.capacity() == w)?;
    assert(s.insert(w - 1))?;
    assert(s.insert(w))?;
    assert(s.capacity() == w + w)?;
    assert(s.insert(w + w))?;
    assert(s.size() == 4)?;
    assert(s.contains(0))?;
    assert(s.contains(w - 1))?;
    assert(s.contains(w))?;
    assert(s.contains(w + w))?;
    assert(s.contains(w + 1) == false)?;
    assert(s.remove(w))?;
    assert(s.contains(w) == false)?;
    assert(s.size() == 3)?;
}

test("bitset with_capacity in bits") {
    let w = bits_per_word();
    let a = BitSet::with_capacity(10);
    assert(a.capacity() == w)?;
    assert(a.is_empty())?;
    let b = BitSet::with_capacity(w + 1);
    assert(b.capacity() == w + w)?;
    assert(b.insert(w))?;
    assert(b.contains(w))?;
    assert(b.size() == 1)?;
}

test("bitset clear keeps capacity") {
    let s = BitSet::with_capacity(100);
    let cap = s.capacity();
    assert(s.insert(0))?;
    assert(s.insert(99))?;
    assert(s.size() == 2)?;
    s.clear();
    assert(s.is_empty())?;
    assert(s.contains(0) == false)?;
    assert(s.contains(99) == false)?;
    assert(s.capacity() == cap)?;
    assert(s.insert(3))?;
    assert(s.size() == 1)?;
}

test("bitset negative indices") {
    let s = BitSet::new();
    assert(s.insert(0 - 1) == false)?;
    assert(s.contains(0 - 1) == false)?;
    assert(s.remove(0 - 1) == false)?;
    assert(s.is_empty())?;
}
