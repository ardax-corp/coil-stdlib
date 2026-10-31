use tests::assert;
use bytes::{slice, concat, eq, find, find_from, rfind, contains, starts_with, ends_with, replace, repeat, pad_left, pad_right};
use string::to_bytes;

test("slice concat eq") {
    let b = to_bytes("hello");
    assert!(eq(slice(b, 1, 4), to_bytes("ell")));
    assert!(eq(concat(to_bytes("ab"), to_bytes("cd")), to_bytes("abcd")));
}

test("find contains affixes") {
    // `to_bytes` / buffer args may invalidate — rebuild hay per call.
    assert!(find(to_bytes("abcdef"), to_bytes("cd")) == Option::Some(2));
    assert!(find(to_bytes("abcdef"), to_bytes("zz")).is_none());
    assert!(contains(to_bytes("abcdef"), to_bytes("de")));
    assert!(starts_with(to_bytes("abcdef"), to_bytes("ab")));
    assert!(ends_with(to_bytes("abcdef"), to_bytes("ef")));
}

test("find_from skips prefix") {
    assert!(find_from(to_bytes("ababab"), to_bytes("ab"), 1) == Option::Some(2));
    assert!(find_from(to_bytes("ababab"), to_bytes("ab"), 2) == Option::Some(2));
    assert!(find_from(to_bytes("ababab"), to_bytes("ab"), 4) == Option::Some(4));
    assert!(find_from(to_bytes("ababab"), to_bytes("ab"), 5).is_none());
    assert!(find_from(to_bytes("abc"), to_bytes(""), 2) == Option::Some(2));
}

test("rfind and replace") {
    assert!(rfind(to_bytes("ababa"), to_bytes("ba")) == Option::Some(3));
    assert!(rfind(to_bytes("abc"), to_bytes("z")).is_none());
    assert!(rfind(to_bytes("abc"), to_bytes("")) == Option::Some(3));
    assert!(eq(replace(to_bytes("aaaa"), to_bytes("aa"), to_bytes("b")), to_bytes("bb")));
    assert!(eq(replace(to_bytes("abc"), to_bytes(""), to_bytes("x")), to_bytes("abc")));
}

test("repeat bytes") {
    assert!(eq(repeat(to_bytes("ab"), 3), to_bytes("ababab")));
    assert!(eq(repeat(to_bytes("ab"), 0), to_bytes("")));
}

test("pad bytes left") {
    assert!(eq(pad_left(to_bytes("7"), 3, "0"), to_bytes("007")));
}

test("pad bytes right") {
    assert!(eq(pad_right(to_bytes("7"), 3, "0"), to_bytes("700")));
}

test("pad bytes preserves wide input") {
    assert!(eq(pad_left(to_bytes("wide"), 2, "0"), to_bytes("wide")));
}

test("eq and affixes on long buffers, a difference anywhere") {
    for n in [0, 1, 63, 64, 65, 200] {
        let a: Vec<byte> = Vec::new();
        let k = 0;
        while k < n {
            a.push((k % 251) as byte);
            k = k + 1;
        }
        assert!(eq(a, slice(a, 0, n)));
        assert!(starts_with(a, slice(a, 0, n / 2)));
        assert!(ends_with(a, slice(a, n / 2, n)));
        for at in [0, n / 2, n - 1] {
            if at >= 0 && at < n {
                let b = slice(a, 0, n);
                b[at] = 255 as byte;
                assert!(!eq(a, b));
                assert!(!starts_with(a, slice(b, 0, at + 1)));
                assert!(starts_with(a, slice(b, 0, at)));
            }
        }
    }
}
