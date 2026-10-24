use tests::assert;
use collections::vec::{map, filter, fold, first, last, contains, index_of, concat, dedup, binary_search, chunks, windows, partition};

test("map int") {
    let xs: Vec<int> = Vec::new();
    xs.push(1);
    xs.push(2);
    xs.push(3);
    let doubled = map(xs, fn (int x) => x + x);
    assert!(doubled.len() == 3);
    assert!(doubled[0] == 2);
    assert!(doubled[2] == 6);
}

test("filter int") {
    let xs: Vec<int> = Vec::new();
    xs.push(1);
    xs.push(2);
    xs.push(3);
    xs.push(4);
    let evens = filter(xs, fn (int x) => x % 2 == 0);
    assert!(evens.len() == 2);
    assert!(evens[0] == 2);
    assert!(evens[1] == 4);
}

test("fold sum") {
    let xs: Vec<int> = Vec::new();
    xs.push(1);
    xs.push(2);
    xs.push(3);
    let sum = fold(xs, 0, fn (int acc, int x) => acc + x);
    assert!(sum == 6);
}

test("first last contains index") {
    let xs: Vec<int> = Vec::new();
    xs.push(10);
    xs.push(20);
    assert!((first(xs) ?? 0) == 10);
    assert!((last(xs) ?? 0) == 20);
    assert!(contains(xs, 20));
    assert!(index_of(xs, 20) == Option::Some(1));
    assert!(index_of(xs, 99).is_none());
}

test("concat dedup chunks") {
    let a: Vec<int> = Vec::new();
    a.push(1);
    let b: Vec<int> = Vec::new();
    b.push(2);
    let c = concat(a, b);
    assert!(c.len() == 2);
    let d: Vec<int> = Vec::new();
    d.push(1);
    d.push(1);
    d.push(2);
    let u = dedup(d);
    assert!(u.len() == 2);
    let parts = chunks(c, 1);
    assert!(parts.len() == 2);
}

test("windows overlapping") {
    let xs: Vec<int> = Vec::new();
    xs.push(1);
    xs.push(2);
    xs.push(3);
    xs.push(4);
    let w = windows(xs, 2);
    assert!(w.len() == 3);
    assert!(w[0].len() == 2);
    assert!(w[0][0] == 1);
    assert!(w[0][1] == 2);
    assert!(w[1][0] == 2);
    assert!(w[1][1] == 3);
    assert!(w[2][0] == 3);
    assert!(w[2][1] == 4);
    let full = windows(xs, 4);
    assert!(full.len() == 1);
    assert!(full[0][0] == 1);
    assert!(full[0][3] == 4);
}

test("windows empty cases") {
    let xs: Vec<int> = Vec::new();
    xs.push(1);
    xs.push(2);
    assert!(windows(xs, 0).len() == 0);
    assert!(windows(xs, 0 - 1).len() == 0);
    assert!(windows(xs, 3).len() == 0);
    let empty: Vec<int> = Vec::new();
    assert!(windows(empty, 1).len() == 0);
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
    assert!(yes.len() == 2);
    assert!(yes[0] == 2);
    assert!(yes[1] == 4);
    assert!(no.len() == 3);
    assert!(no[0] == 1);
    assert!(no[1] == 3);
    assert!(no[2] == 5);
}

test("partition all none empty") {
    let xs: Vec<int> = Vec::new();
    xs.push(2);
    xs.push(4);
    let all_yes = partition(xs, fn (int x) => x % 2 == 0);
    assert!(all_yes.matched().len() == 2);
    assert!(all_yes.matched()[0] == 2);
    assert!(all_yes.matched()[1] == 4);
    assert!(all_yes.rest().len() == 0);
    let none = partition(xs, fn (int x) => x < 0);
    assert!(none.matched().len() == 0);
    assert!(none.rest().len() == 2);
    assert!(none.rest()[0] == 2);
    assert!(none.rest()[1] == 4);
    let empty: Vec<int> = Vec::new();
    let z = partition(empty, fn (int x) => x == 0);
    assert!(z.matched().len() == 0);
    assert!(z.rest().len() == 0);
}

test("windows size one and three") {
    let xs: Vec<int> = Vec::new();
    xs.push(10);
    xs.push(20);
    xs.push(30);
    xs.push(40);
    xs.push(50);
    let ones = windows(xs, 1);
    assert!(ones.len() == 5);
    assert!(ones[0][0] == 10);
    assert!(ones[4][0] == 50);
    let w3 = windows(xs, 3);
    assert!(w3.len() == 3);
    assert!(w3[0][0] == 10);
    assert!(w3[0][2] == 30);
    assert!(w3[1][0] == 20);
    assert!(w3[1][2] == 40);
    assert!(w3[2][0] == 30);
    assert!(w3[2][2] == 50);
    assert!(xs[0] == 10);
    assert!(xs[4] == 50);
}

test("partition preserves input") {
    let xs: Vec<int> = Vec::new();
    xs.push(1);
    xs.push(2);
    xs.push(3);
    let p = partition(xs, fn (int x) => x == 2);
    assert!(xs[0] == 1);
    assert!(xs[1] == 2);
    assert!(xs[2] == 3);
    assert!(p.matched().len() == 1);
    assert!(p.matched()[0] == 2);
    assert!(p.rest().len() == 2);
    assert!(p.rest()[0] == 1);
    assert!(p.rest()[1] == 3);
}

test("binary search") {
    let xs: Vec<int> = Vec::new();
    xs.push(1);
    xs.push(3);
    xs.push(5);
    assert!((binary_search(xs, 3) ?? -1) == 1);
    assert!((binary_search(xs, 4) ?? -1) == -1);
}

test("map string") {
    let xs: Vec<string> = Vec::new();
    xs.push("a");
    xs.push("b");
    let out = map(xs, fn (string s) => s + s);
    assert!(out.len() == 2);
    assert!(out[0] == "aa");
}
