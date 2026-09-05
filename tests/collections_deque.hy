use collections::deque::{VecDeque};

test("deque push pop both ends") {
    let xs = VecDeque::new();
    assert(xs.is_empty())?;
    xs.push_front(1);
    xs.push_front(2);
    xs.push_back(3);
    assert(xs.size() == 3)?;
    assert((xs.peek_front() ?? 0) == 2)?;
    assert((xs.peek_back() ?? 0) == 3)?;
    assert((xs.pop_front() ?? 0) == 2)?;
    assert((xs.pop_back() ?? 0) == 3)?;
    assert((xs.pop_front() ?? 0) == 1)?;
    assert((xs.pop_front() ?? -1) == -1)?;
    assert((xs.pop_back() ?? -1) == -1)?;
    assert(xs.is_empty())?;
    xs.push_front(9);
    xs.clear();
    assert(xs.is_empty())?;
    assert((xs.peek_front() ?? -7) == -7)?;
    assert((xs.peek_back() ?? -7) == -7)?;
}

test("deque wraparound then grow") {
    let xs = VecDeque::with_capacity(8);
    assert(xs.capacity() == 8)?;
    let i = 0;
    while i < 8 {
        xs.push_back(i);
        i = i + 1;
    }
    assert((xs.pop_front() ?? -1) == 0)?;
    assert((xs.pop_front() ?? -1) == 1)?;
    xs.push_back(8);
    xs.push_back(9);
    assert(xs.size() == 8)?;
    assert(xs.capacity() == 8)?;
    xs.push_back(10);
    assert(xs.capacity() == 16)?;
    assert(xs.size() == 9)?;
    let v = xs.to_vec();
    assert(len(v) == 9)?;
    assert(v[0] == 2)?;
    assert(v[7] == 9)?;
    assert(v[8] == 10)?;
    assert((xs.peek_front() ?? 0) == 2)?;
    assert((xs.peek_back() ?? 0) == 10)?;
}

test("deque push_front wrap and grow") {
    let xs = VecDeque::with_capacity(8);
    let i = 0;
    while i < 8 {
        xs.push_front(i);
        i = i + 1;
    }
    assert(xs.size() == 8)?;
    assert(xs.capacity() == 8)?;
    xs.push_front(8);
    assert(xs.capacity() == 16)?;
    assert((xs.pop_front() ?? -1) == 8)?;
    assert((xs.pop_back() ?? -1) == 0)?;
    assert((xs.pop_front() ?? -1) == 7)?;
}

test("deque to_vec and clear reuse") {
    let xs = VecDeque::new();
    xs.push_back(1);
    xs.push_back(2);
    xs.push_back(3);
    let v = xs.to_vec();
    assert(len(v) == 3)?;
    assert(v[0] == 1)?;
    assert(v[2] == 3)?;
    xs.clear();
    assert(xs.is_empty())?;
    xs.push_back(4);
    assert(xs.size() == 1)?;
    assert((xs.peek_front() ?? 0) == 4)?;
}

test("deque capacity power of two") {
    let a = VecDeque::with_capacity(3);
    assert(a.capacity() == 8)?;
    let b = VecDeque::with_capacity(16);
    assert(b.capacity() == 16)?;
}
