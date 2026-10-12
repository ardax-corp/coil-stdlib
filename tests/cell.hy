use tests::assert;
use cell::Ref;

test("ref get set replace") {
    let r = Ref::new(1);
    assert!(r.get() == 1);
    r.set(2);
    assert!(r.get() == 2);
    assert!(r.replace(5) == 2);
    assert!(r.get() == 5);
}

test("ref update returns new value") {
    let r = Ref::new(10);
    assert!(r.update(fn (int x) => x + 1) == 11);
    assert!(r.get() == 11);
}

test("ref shared through lambda capture") {
    let count = Ref::new(0);
    let bump = fn () use (count) => count.update(fn (int x) => x + 1);
    bump();
    bump();
    bump();
    assert!(count.get() == 3);
}

test("ref shared through defer capture") {
    let log = Ref::new("");
    run_with_defer(log);
    assert!(log.get() == "done");
}

fn run_with_defer(Ref<string> log) {
    defer use (log) {
        log.set("done");
    }
    log.set("working");
}

test("ref holds heap values") {
    let r: Ref<Vec<int>> = Ref::new(Vec::new());
    r.get().push(1);
    r.set([7, 8]);
    assert!(len(r.get()) == 2);
}
