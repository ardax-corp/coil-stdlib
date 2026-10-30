use tests::assert;
use cell::Ref;
use future::{Promise, Group, all, try_all, race, first_ok, limit};
use task::{scope, Scope, Task, TaskError, sleep, yield_now};

test("promise resolves every waiter") {
    let r = scope(fn (Scope s) {
        let p: Promise<int> = Promise::new();
        let a = s.spawn(fn () use (p) => p.wait().unwrap_or(0));
        let b = s.spawn(fn () use (p) => p.wait().unwrap_or(0));
        s.spawn(fn () use (p) {
            sleep(2);
            p.resolve(21);
        });
        return a.join().unwrap_or(0) + b.join().unwrap_or(0);
    });
    assert!(r.unwrap_or(0) == 42);
}

test("promise first resolve wins") {
    let p: Promise<string> = Promise::new();
    assert!(!p.is_done());
    assert!(p.try_get().is_none());
    assert!(p.resolve("a"));
    assert!(!p.resolve("b"));
    assert!(!p.cancel());
    assert!(p.is_done());
    assert!(p.wait().unwrap_or("") == "a");
    assert!(p.try_get() == Option::Some("a"));
}

test("promise already resolved") {
    let p = Promise::resolved(7);
    assert!(p.wait().unwrap_or(0) == 7);
    assert!(p.wait_timeout(1).unwrap_or(0) == 7);
}

test("cancelled promise wakes its waiters with Cancelled") {
    let r = scope(fn (Scope s) {
        let p: Promise<int> = Promise::new();
        let w = s.spawn(fn () use (p) => p.wait());
        s.spawn(fn () use (p) {
            yield_now();
            p.cancel();
        });
        return w.join();
    });
    let cancelled = match r {
        Result::Ok(Result::Ok(Result::Err(TaskError::Cancelled))) => true,
        default => false,
    };
    assert!(cancelled);
}

test("promise wait_timeout") {
    let r = scope(fn (Scope s) {
        let p: Promise<int> = Promise::new();
        let late = p.wait_timeout(5);
        s.spawn(fn () use (p) {
            sleep(1);
            p.resolve(3);
        });
        let soon = p.wait_timeout(1000);
        let timed_out = match late {
            Result::Err(TaskError::TimedOut) => true,
            default => false,
        };
        return timed_out && soon == Result::Ok(3);
    });
    assert!(r.unwrap_or(false));
}

test("group hands children back in completion order") {
    let r = scope(fn (Scope s) {
        let g: Group<int> = Group::new(s);
        g.spawn(fn () {
            sleep(30);
            return 1;
        });
        g.spawn(fn () {
            sleep(1);
            return 2;
        });
        g.spawn(fn () {
            sleep(10);
            return 3;
        });
        let started = g.len();
        let order = 0;
        while let Option::Some(t) = g.next() {
            order = order * 10 + t.join().unwrap_or(0);
        }
        if started != 3 || g.pending() != 0 || g.next().is_some() {
            return -1;
        }
        return order;
    });
    assert!(r.unwrap_or(0) == 231);
}

test("group next_index and task") {
    let r = scope(fn (Scope s) {
        let g: Group<string> = Group::new(s);
        g.spawn(fn () {
            sleep(5);
            return "a";
        });
        g.spawn(fn () => "b");
        let i = g.next_index().unwrap_or(-1);
        return i == 1 && g.task(i).join().unwrap_or("") == "b";
    });
    assert!(r.unwrap_or(false));
}

test("group cancel_all unwinds the losers and still reports them") {
    let unwound = Ref::new(0);
    let r = scope(fn (Scope s) use (unwound) {
        let g: Group<int> = Group::new(s);
        g.spawn(fn () => 1);
        g.spawn(fn () use (unwound) {
            defer use (unwound) {
                unwound.update(fn (int n) => n + 1);
            }
            sleep(10000);
            return 2;
        });
        let first = match g.next() {
            Option::Some(t) => t.join().unwrap_or(0),
            Option::None => 0,
        };
        g.cancel_all();
        let cancelled = match g.next() {
            Option::Some(t) => match t.join() {
                Result::Err(TaskError::Cancelled) => true,
                default => false,
            },
            Option::None => false,
        };
        if !cancelled {
            return -1;
        }
        return first;
    });
    assert!(r.unwrap_or(0) == 1);
    assert!(unwound.get() == 1);
}

test("all keeps input order") {
    let bodies: Vec<unit -> int> = Vec::new();
    bodies.push(fn () {
        sleep(10);
        return 1;
    });
    bodies.push(fn () => 2);
    bodies.push(fn () {
        sleep(3);
        return 3;
    });
    let ok = match all(bodies) {
        Result::Ok(v) => v.len() == 3 && v[0] == 1 && v[1] == 2 && v[2] == 3,
        Result::Err(_) => false,
    };
    assert!(ok);
    let none: Vec<unit -> int> = Vec::new();
    let empty = match all(none) {
        Result::Ok(v) => v.len() == 0,
        Result::Err(_) => false,
    };
    assert!(empty);
}

test("a panicking body fails all") {
    let bodies: Vec<unit -> int> = Vec::new();
    bodies.push(fn () => 1);
    bodies.push(fn () {
        panic "boom";
    });
    let failed = match all(bodies) {
        Result::Err(TaskError::Panicked(m)) => m == "boom",
        default => false,
    };
    assert!(failed);
}

test("limit caps how many run at once") {
    let running = Ref::new(0);
    let peak = Ref::new(0);
    let bodies: Vec<unit -> int> = Vec::new();
    let i = 0;
    while i < 6 {
        let k = i;
        bodies.push(fn () use (running, peak, k) {
            let now = running.update(fn (int n) => n + 1);
            if now > peak.get() {
                peak.set(now);
            }
            sleep(2);
            running.update(fn (int n) => n - 1);
            return k * k;
        });
        i = i + 1;
    }
    let ok = match limit(2, bodies) {
        Result::Ok(v) => v.len() == 6 && v[0] == 0 && v[3] == 9 && v[5] == 25,
        Result::Err(_) => false,
    };
    assert!(ok);
    assert!(peak.get() == 2);
}

test("try_all collects Ok values in input order") {
    let bodies: Vec<unit -> Result<int, string>> = Vec::new();
    bodies.push(fn () {
        sleep(3);
        return Result::Ok(1);
    });
    bodies.push(fn () => Result::Ok(2));
    let ok = match try_all(bodies) {
        Result::Ok(v) => v.len() == 2 && v[0] == 1 && v[1] == 2,
        Result::Err(_) => false,
    };
    assert!(ok);
}

test("try_all returns the first Err and cancels the rest") {
    let unwound = Ref::new(false);
    let bodies: Vec<unit -> Result<int, string>> = Vec::new();
    bodies.push(fn () use (unwound) {
        defer use (unwound) {
            unwound.set(true);
        }
        sleep(10000);
        return Result::Ok(1);
    });
    bodies.push(fn () {
        sleep(1);
        return Result::Err("bad");
    });
    assert!(try_all(bodies) == Result::Err("bad"));
    assert!(unwound.get());
}

test("race returns the first finisher and cancels the others") {
    let unwound = Ref::new(false);
    let bodies: Vec<unit -> string> = Vec::new();
    bodies.push(fn () use (unwound) {
        defer use (unwound) {
            unwound.set(true);
        }
        sleep(10000);
        return "slow";
    });
    bodies.push(fn () {
        sleep(1);
        return "fast";
    });
    let winner = race(bodies);
    assert!(winner == Result::Ok("fast"));
    assert!(unwound.get());
}

test("first_ok returns the first Ok") {
    let bodies: Vec<unit -> Result<int, string>> = Vec::new();
    bodies.push(fn () => Result::Err("down"));
    bodies.push(fn () {
        sleep(2);
        return Result::Ok(7);
    });
    bodies.push(fn () {
        sleep(10000);
        return Result::Ok(8);
    });
    let got = first_ok(bodies);
    assert!(got == Result::Ok(7));
}

test("first_ok returns every error in input order") {
    let bodies: Vec<unit -> Result<int, string>> = Vec::new();
    bodies.push(fn () {
        sleep(3);
        return Result::Err("a");
    });
    bodies.push(fn () => Result::Err("b"));
    let ok = match first_ok(bodies) {
        Result::Err(errs) => errs.len() == 2 && errs[0] == "a" && errs[1] == "b",
        Result::Ok(_) => false,
    };
    assert!(ok);
}

test("combinators run inside a generic caller") {
    assert!(both(4, 5) == 2);
    assert!(both("x", "y") == 2);
}

fn both<T>(T a, T b) -> int {
    let bodies: Vec<unit -> T> = Vec::new();
    bodies.push(fn () use (a) => a);
    bodies.push(fn () use (b) => b);
    return match all(bodies) {
        Result::Ok(v) => __weight(v),
        Result::Err(_) => -1,
    };
}

fn __weight<T>(Vec<T> v) -> int {
    return v.len();
}
