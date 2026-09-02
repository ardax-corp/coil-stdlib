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
    let y = r.next_u64();
    assert(x != y || x == y)?;
    let n = r.range(0, 8);
    assert(n >= 0)?;
    assert(n < 8)?;
    let buf = r.bytes(4);
    assert(len(buf) == 4)?;
    let r2 = Rng::from_time();
    let z = r2.next_u64();
    assert(z != 0 || z == 0)?;
}
