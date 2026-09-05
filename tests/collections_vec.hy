use collections::vec::{
    map, filter, fold, first, last, contains, index_of, concat, dedup, binary_search, chunks,
    windows, partition,
};

test("map int") {
    let xs: Vec<int> = Vec::new();
    xs.push(1);
    xs.push(2);
    xs.push(3);
    let doubled = map(xs, fn (int x) => x + x);
    assert(len(doubled) == 3)?;
    assert(doubled[0] == 2)?;
    assert(doubled[2] == 6)?;
}

test("filter int") {
    let xs: Vec<int> = Vec::new();
    xs.push(1);
    xs.push(2);
    xs.push(3);
    xs.push(4);
    let evens = filter(xs, fn (int x) => x % 2 == 0);
    assert(len(evens) == 2)?;
    assert(evens[0] == 2)?;
    assert(evens[1] == 4)?;
}

test("fold sum") {
    let xs: Vec<int> = Vec::new();
    xs.push(1);
    xs.push(2);
    xs.push(3);
    let sum = fold(xs, 0, fn (int acc, int x) => acc + x);
    assert(sum == 6)?;
}

test("first last contains index") {
    let xs: Vec<int> = Vec::new();
    xs.push(10);
    xs.push(20);
    assert((first(xs) ?? 0) == 10)?;
    assert((last(xs) ?? 0) == 20)?;
    assert(contains(xs, 20))?;
    assert(index_of(xs, 20) == 1)?;
    assert(index_of(xs, 99) < 0)?;
}

test("concat dedup chunks") {
    let a: Vec<int> = Vec::new();
    a.push(1);
    let b: Vec<int> = Vec::new();
    b.push(2);
    let c = concat(a, b);
    assert(len(c) == 2)?;
    let d: Vec<int> = Vec::new();
    d.push(1);
    d.push(1);
    d.push(2);
    let u = dedup(d);
    assert(len(u) == 2)?;
    let parts = chunks(c, 1);
    assert(len(parts) == 2)?;
}

test("windows overlapping") {
    let xs: Vec<int> = Vec::new();
    xs.push(1);
    xs.push(2);
    xs.push(3);
    xs.push(4);
    let w = windows(xs, 2);
    assert(len(w) == 3)?;
    assert(len(w[0]) == 2)?;
    assert(w[0][0] == 1)?;
    assert(w[0][1] == 2)?;
    assert(w[1][0] == 2)?;
    assert(w[1][1] == 3)?;
    assert(w[2][0] == 3)?;
    assert(w[2][1] == 4)?;
    let full = windows(xs, 4);
    assert(len(full) == 1)?;
    assert(full[0][0] == 1)?;
    assert(full[0][3] == 4)?;
}

test("windows empty cases") {
    let xs: Vec<int> = Vec::new();
    xs.push(1);
    xs.push(2);
    assert(len(windows(xs, 0)) == 0)?;
    assert(len(windows(xs, 0 - 1)) == 0)?;
    assert(len(windows(xs, 3)) == 0)?;
    let empty: Vec<int> = Vec::new();
    assert(len(windows(empty, 1)) == 0)?;
}

test("partition even odd") {
    let xs: Vec<int> = Vec::new();
    xs.push(1);
    xs.push(2);
    xs.push(3);
    xs.push(4);
    xs.push(5);
    let p = partition(xs, fn (int x) => x % 2 == 0);
    let yes = p.matched();
    let no = p.rest();
    assert(len(yes) == 2)?;
    assert(yes[0] == 2)?;
    assert(yes[1] == 4)?;
    assert(len(no) == 3)?;
    assert(no[0] == 1)?;
    assert(no[1] == 3)?;
    assert(no[2] == 5)?;
}

test("partition all none empty") {
    let xs: Vec<int> = Vec::new();
    xs.push(2);
    xs.push(4);
    let all_yes = partition(xs, fn (int x) => x % 2 == 0);
    assert(len(all_yes.matched()) == 2)?;
    assert(len(all_yes.rest()) == 0)?;
    let none = partition(xs, fn (int x) => x < 0);
    assert(len(none.matched()) == 0)?;
    assert(len(none.rest()) == 2)?;
    let empty: Vec<int> = Vec::new();
    let z = partition(empty, fn (int x) => x == 0);
    assert(len(z.matched()) == 0)?;
    assert(len(z.rest()) == 0)?;
}

test("binary search") {
    let xs: Vec<int> = Vec::new();
    xs.push(1);
    xs.push(3);
    xs.push(5);
    assert((binary_search(xs, 3) ?? -1) == 1)?;
    assert((binary_search(xs, 4) ?? -1) == -1)?;
}

test("map string") {
    let xs: Vec<string> = Vec::new();
    xs.push("a");
    xs.push("b");
    let out = map(xs, fn (string s) => s + s);
    assert(len(out) == 2)?;
    assert(out[0] == "aa")?;
}
