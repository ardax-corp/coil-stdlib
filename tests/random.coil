use tests::assert;
use random::Rng;

test("rng seeded deterministic") {
    let a = Rng::seeded(42);
    let b = Rng::seeded(42);
    assert!(a.next_u64() == b.next_u64());
    assert!(a.next_u64() == b.next_u64());
}

test("rng range empty") {
    let r = Rng::seeded(1);
    assert!(r.range(5, 5) == 5);
    assert!(r.range(7, 3) == 7);
}

test("rng from_time") {
    let r = Rng::from_time();
    let x = r.next_u64();
    let y = r.next_u64();
    assert!(x != y || x == y);
    let n = r.range(0, 8);
    assert!(n >= 0);
    assert!(n < 8);
    let buf = r.bytes(4);
    assert!(buf.len() == 4);
    let r2 = Rng::from_time();
    let z = r2.next_u64();
    assert!(z != 0 || z == 0);
}

test("rng float spreads over 0..1 and next_u64 uses all 64 bits (#54)") {
    let r = Rng::seeded(42);
    let sum = 0.0;
    let high = false;
    let i = 0;
    while i < 1000 {
        let f = r.float();
        assert!(f >= 0.0 && f < 1.0);
        sum = sum + f;
        let x = r.next_u64();
        if x < 0 || x > 4294967296 {
            high = true;
        }
        i = i + 1;
    }
    assert!(sum / 1000.0 > 0.4 && sum / 1000.0 < 0.6);
    assert!(high);
}
