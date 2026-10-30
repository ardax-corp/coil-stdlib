use tests::assert;
use timer::{Interval, sleep_until};
use clock::{mono_nanos};
use task::{sleep};

test("sleep_until waits for the deadline") {
    let deadline = mono_nanos() + 3000000;
    sleep_until(deadline);
    assert!(mono_nanos() >= deadline);
    // A deadline in the past returns at once.
    sleep_until(0);
}

test("interval ticks count periods from the start") {
    let start = mono_nanos();
    let every = Interval::new(2);
    assert!(every.period() == 2);
    assert!(every.tick() == 1);
    assert!(every.tick() == 2);
    assert!(every.tick() == 3);
    assert!(mono_nanos() - start >= 6000000);
}

test("a late interval skips the periods it missed") {
    let every = Interval::new(2);
    sleep(9);
    let n = every.tick();
    assert!(n >= 4);
    assert!(every.tick() == n + 1);
}
