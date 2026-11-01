// `sort` on a `Vec` of tuples orders them lexicographically: a tuple whose
// elements are all `Ord` is `Ord` (coil-lang#1721).
use tests::assert;
use collections::{sort, sort_by};

test("sort Vec<(int, string)>") {
    let v: Vec<(int, string)> = Vec::new();
    v.push((2, "b"));
    v.push((1, "z"));
    v.push((2, "a"));
    v.push((1, "a"));
    let s = sort(v);
    assert!(s[0] == (1, "a"));
    assert!(s[1] == (1, "z"));
    assert!(s[2] == (2, "a"));
    assert!(s[3] == (2, "b"));
    assert!(v[0] == (2, "b"));
}

test("sort nested tuples") {
    let s = sort(Vec::from([((1, 2), 0), ((0, 9), 5), ((1, 1), 7)]));
    assert!(s[0] == ((0, 9), 5));
    assert!(s[1] == ((1, 1), 7));
    assert!(s[2] == ((1, 2), 0));
}

test("sort_by a tuple key") {
    let words = Vec::from(["bb", "a", "ab", "c"]);
    let s = sort_by(words, fn (string w) => (w.len(), w));
    assert!(s[0] == "a");
    assert!(s[1] == "c");
    assert!(s[2] == "ab");
    assert!(s[3] == "bb");
}
