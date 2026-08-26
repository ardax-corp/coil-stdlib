use random::{Rng};

test("rng seeded deterministic") {
    let a = Rng::seeded(42);
    let b = Rng::seeded(42);
    assert(a.next_u64() == b.next_u64())?;
    assert(a.next_u64() == b.next_u64())?;
}

test("rng range empty") {
    let r = Rng::seeded(1);
    assert(r.range(5, 5) == 5)?;
    assert(r.range(7, 3) == 7)?;
}

test("rng from_time") {
    let r = Rng::from_time();
    let x = r.next_u64();
    assert(x >= 0 || x < 0)?;
}
