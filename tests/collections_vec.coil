use tests::assert;
use collections::vec::{VecOps, VecEq, VecOrd, VecSum};

test("map int") {
    let xs: Vec<int> = Vec::new();
    xs.push(1);
    xs.push(2);
    xs.push(3);
    let doubled = xs.map(fn (int x) => x + x);
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
    let evens = xs.filter(fn (int x) => x % 2 == 0);
    assert!(evens.len() == 2);
    assert!(evens[0] == 2);
    assert!(evens[1] == 4);
}

test("fold sum") {
    let xs: Vec<int> = Vec::new();
    xs.push(1);
    xs.push(2);
    xs.push(3);
    let sum = xs.fold(0, fn (int acc, int x) => acc + x);
    assert!(sum == 6);
}

test("first last contains index") {
    let xs: Vec<int> = Vec::new();
    xs.push(10);
    xs.push(20);
    assert!((xs.first() ?? 0) == 10);
    assert!((xs.last() ?? 0) == 20);
    assert!(xs.contains(20));
    assert!(xs.index_of(20) == Option::Some(1));
    assert!(xs.index_of(99).is_none());
}

test("concat dedup chunks") {
    let a: Vec<int> = Vec::new();
    a.push(1);
    let b: Vec<int> = Vec::new();
    b.push(2);
    let c = a.concat(b);
    assert!(c.len() == 2);
    let d: Vec<int> = Vec::new();
    d.push(1);
    d.push(1);
    d.push(2);
    let u = d.dedup();
    assert!(u.len() == 2);
    let parts = c.chunks(1);
    assert!(parts.len() == 2);
}

test("windows overlapping") {
    let xs: Vec<int> = Vec::new();
    xs.push(1);
    xs.push(2);
    xs.push(3);
    xs.push(4);
    let w = xs.windows(2);
    assert!(w.len() == 3);
    assert!(w[0].len() == 2);
    assert!(w[0][0] == 1);
    assert!(w[0][1] == 2);
    assert!(w[1][0] == 2);
    assert!(w[1][1] == 3);
    assert!(w[2][0] == 3);
    assert!(w[2][1] == 4);
    let full = xs.windows(4);
    assert!(full.len() == 1);
    assert!(full[0][0] == 1);
    assert!(full[0][3] == 4);
}

test("windows empty cases") {
    let xs: Vec<int> = Vec::new();
    xs.push(1);
    xs.push(2);
    assert!(xs.windows(0).len() == 0);
    assert!(xs.windows(-1).len() == 0);
    assert!(xs.windows(3).len() == 0);
    let empty: Vec<int> = Vec::new();
    assert!(empty.windows(1).len() == 0);
}

test("partition even odd") {
    let xs: Vec<int> = Vec::new();
    xs.push(1);
    xs.push(2);
    xs.push(3);
    xs.push(4);
    xs.push(5);
    let p = xs.partition(fn (int x) => x % 2 == 0);
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
    let all_yes = xs.partition(fn (int x) => x % 2 == 0);
    assert!(all_yes.matched().len() == 2);
    assert!(all_yes.matched()[0] == 2);
    assert!(all_yes.matched()[1] == 4);
    assert!(all_yes.rest().len() == 0);
    let none = xs.partition(fn (int x) => x < 0);
    assert!(none.matched().len() == 0);
    assert!(none.rest().len() == 2);
    assert!(none.rest()[0] == 2);
    assert!(none.rest()[1] == 4);
    let empty: Vec<int> = Vec::new();
    let z = empty.partition(fn (int x) => x == 0);
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
    let ones = xs.windows(1);
    assert!(ones.len() == 5);
    assert!(ones[0][0] == 10);
    assert!(ones[4][0] == 50);
    let w3 = xs.windows(3);
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
    let p = xs.partition(fn (int x) => x == 2);
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
    assert!((xs.binary_search(3) ?? -1) == 1);
    assert!((xs.binary_search(4) ?? -1) == -1);
}

test("map string") {
    let xs: Vec<string> = Vec::new();
    xs.push("a");
    xs.push("b");
    let out = xs.map(fn (string s) => s + s);
    assert!(out.len() == 2);
    assert!(out[0] == "aa");
}

test("enumerate gives index and value pairs for a tuple for-loop") {
    let xs: Vec<string> = ["a", "b", "c"];
    let seen = 0;
    for (i, x) in xs.enumerate() {
        assert!(xs[i] == x);
        seen += 1;
    }
    assert!(seen == 3);
}

test("zip stops at the shorter vector") {
    let xs: Vec<int> = [1, 2, 3];
    let ys: Vec<string> = ["a", "b"];
    let pairs = xs.zip(ys);
    assert!(pairs.len() == 2);
    assert!(pairs[1][0] == 2 && pairs[1][1] == "b");
}

test("any all count take skip") {
    let xs: Vec<int> = [1, 2, 3, 4];
    assert!(xs.any(fn (int x) => x > 3));
    assert!(!xs.all(fn (int x) => x > 3));
    assert!(xs.all(fn (int x) => x > 0));
    assert!(xs.count(fn (int x) => x % 2 == 0) == 2);
    assert!(xs.take(2).len() == 2 && xs.take(2)[1] == 2);
    assert!(xs.take(9).len() == 4 && xs.take(-1).len() == 0);
    assert!(xs.skip(3).len() == 1 && xs.skip(3)[0] == 4);
    assert!(xs.skip(9).len() == 0);
}

test("fold over any element and accumulator type") {
    let words: Vec<string> = ["ab", "cde"];
    assert!(words.fold(0, fn (int n, string w) => n + w.len()) == 5);
    let xs: Vec<int> = [1, 2];
    assert!(xs.fold("", fn (string acc, int x) => acc + x.show()) == "12");
}

test("sum of int and float vectors") {
    let xs: Vec<int> = [1, 2, 3];
    let fs: Vec<float> = [0.5, 0.25];
    let none: Vec<int> = Vec::new();
    assert!(xs.sum() == 6);
    assert!(fs.sum() == 0.75);
    assert!(none.sum() == 0);
}

test("min and max over any ordered element") {
    let xs: Vec<int> = [3, 9, 1];
    let words: Vec<string> = ["pear", "apple"];
    let none: Vec<int> = Vec::new();
    assert!(xs.min() == Option::Some(1));
    assert!(xs.max() == Option::Some(9));
    assert!((words.min() ?? "") == "apple");
    assert!(none.max().is_none());
}

#[derive(Eq)]
enum Suit {
    Hearts,
    Spades,
}

test("contains index_of dedup over any Eq element") {
    let fs: Vec<float> = [1.5, 1.5, 2.5];
    assert!(fs.contains(2.5) && !fs.contains(3.0));
    assert!(fs.index_of(2.5) == Option::Some(2));
    assert!(fs.dedup().len() == 2);
    let suits: Vec<Suit> = [Suit::Hearts, Suit::Spades];
    assert!(suits.contains(Suit::Spades));
    assert!(suits.index_of(Suit::Hearts) == Option::Some(0));
    let words: Vec<string> = ["a", "a", "b"];
    assert!(words.dedup().len() == 2 && words.index_of("b") == Option::Some(2));
}

test("binary search over strings") {
    let words: Vec<string> = ["ant", "bee", "cat"];
    assert!((words.binary_search("cat") ?? -1) == 2);
    assert!(words.binary_search("dog").is_none());
}

test("map then filter chains left to right") {
    let xs: Vec<int> = [1, 2, 3, 4];
    let out = xs.map(fn (int x) => x * 10).filter(fn (int x) => x > 15);
    assert!(out.len() == 3 && out[0] == 20);
}
