use collections::vec::{
    map, filter, fold, first, last, contains, index_of, concat, dedup, binary_search, chunks,
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

test("empty first last and uneven chunks") {
    let empty: Vec<int> = Vec::new();
    assert((first(empty) ?? -1) == -1)?;
    assert((last(empty) ?? -1) == -1)?;
    let xs: Vec<int> = Vec::new();
    xs.push(1);
    xs.push(2);
    xs.push(3);
    let parts = chunks(xs, 2);
    assert(len(parts) == 2)?;
    assert(len(parts[0]) == 2)?;
    assert(parts[0][0] == 1)?;
    assert(parts[0][1] == 2)?;
    assert(len(parts[1]) == 1)?;
    assert(parts[1][0] == 3)?;
    let none = chunks(xs, 0);
    assert(len(none) == 0)?;
}

test("binary search edges") {
    let empty: Vec<int> = Vec::new();
    assert((binary_search(empty, 1) ?? -1) == -1)?;
    let xs: Vec<int> = Vec::new();
    xs.push(1);
    xs.push(3);
    xs.push(5);
    assert((binary_search(xs, 1) ?? -1) == 0)?;
    assert((binary_search(xs, 5) ?? -1) == 2)?;
}
