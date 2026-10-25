use tests::assert;
use text::{Searchable, Span, Text, join};

test("trim and affixes") {
    assert!("  hi  ".trim() == "hi");
    assert!("  hi  ".trim_start() == "hi  ");
    assert!("  hi  ".trim_end() == "  hi");
    assert!("hello".starts_with("he"));
    assert!("hello".ends_with("lo"));
    assert!("hello".contains("ell"));
}

test("split and case") {
    let parts = "a,b,c".split(",");
    assert!(parts.len() == 3);
    assert!(parts[0] == "a");
    assert!(parts[2] == "c");
    assert!("AbC".to_lower() == "abc");
    assert!("AbC".to_upper() == "ABC");
}

test("replace split once and join") {
    assert!("one two two".replace_all("two", "2") == "one 2 2");
    let pair = "key=value=rest".split_once("=") ?? ("", "");
    assert!(pair[0] == "key");
    assert!(pair[1] == "value=rest");

    let parts: Vec<string> = Vec::new();
    parts.push("a");
    parts.push("b");
    parts.push("c");
    assert!(join(parts, "::") == "a::b::c");
}

test("repeat text") {
    assert!("ab".repeat(3) == "ababab");
    assert!("ab".repeat(-1) == "");
}

test("pad text left") {
    assert!("7".pad_left(3, "0") == "007");
}

test("pad text right") {
    assert!("7".pad_right(3, "0") == "700");
}

test("pad text preserves wide input") {
    assert!("wide".pad_right(2, "0") == "wide");
}

test("lines handles crlf") {
    let rows = "a\r\nb".lines();
    assert!(rows.len() == 2);
    assert!(rows[0] == "a");
    assert!(rows[1] == "b");
}

test("a final newline ends the last line rather than starting a new one (#74)") {
    let rows = "a\r\nb\n".lines();
    assert!(rows.len() == 2);
    assert!(rows[0] == "a");
    assert!(rows[1] == "b");
    let one = "a\r\n".lines();
    assert!(one.len() == 1);
}

test("lines keeps empty lines in the middle and at the end") {
    let rows = "a\n\nb\n\n".lines();
    assert!(rows.len() == 4);
    assert!(rows[1] == "");
    assert!(rows[3] == "");
}

test("lines of empty text is empty") {
    let none = "".lines();
    assert!(none.len() == 0);
    let blank = "\n".lines();
    assert!(blank.len() == 1);
    assert!(blank[0] == "");
}

test("pad with an empty fill returns the text unchanged") {
    assert!("7".pad_left(3, "") == "7");
    assert!("7".pad_right(3, "") == "7");
}

test("pad repeats a longer fill until the width is reached") {
    assert!("7".pad_left(4, "ab") == "abab7");
    assert!("7".pad_right(2, "ab") == "7ab");
}

test("slice and split_at fail inside a multi-byte character") {
    assert!(("hello".slice(1, 4) ?? "") == "ell");
    assert!("h\u{e9}llo".slice(0, 2).is_err());
    let (a, b) = "hello".split_at(2) ?? ("", "");
    assert!(a == "he" && b == "llo");
    assert!("h\u{e9}llo".split_at(2).is_err());
}

test("text methods compose without ? in a plain function") {
    let words: Vec<string> = Vec::new();
    for line in " Alpha \n beta\n".lines() {
        words.push(line.trim().to_lower());
    }
    assert!(words.len() == 2 && words[0] == "alpha" && words[1] == "beta");
}

test("rfind gives the span of the last match, or None") {
    let at = "a=b=c".rfind("=") ?? new Span(-1, -1);
    assert!(at.start == 3 && at.end == 4);
    assert!("abc".rfind("z").is_none());
    let empty = "abc".rfind("") ?? new Span(-1, -1);
    assert!(empty.start == 3);
}
