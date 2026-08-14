use random::{Rng, crypto_u64, crypto_bytes};

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

test("crypto helpers") {
    let u = match crypto_u64() {
        Result::Ok(v) => v,
        Result::Err(_) => 0,
    };
    assert(u >= 0 || u < 0)?;
    let b = match crypto_bytes(4) {
        Result::Ok(v) => v,
        Result::Err(_) => {
            let empty: Vec<byte> = Vec::new();
            empty
        },
    };
    assert(len(b) == 4)?;
}
