use tests::assert;
use text::{Pattern, Searchable, Span, contains, split};

class Version {
    pub major: int,
    pub minor: int,
}

impl Show for Version {
    pub fn show(Version v) -> string {
        return string::format("%i.%i", v.major, v.minor);
    }
}

impl Searchable for Version {
}

// A pattern that matches any one ASCII digit.
class Digit {}

impl Pattern for Digit {
    pub fn find_in(Digit d, string hay, int from) -> Option<Span> {
        let i = from;
        while i < hay.len() {
            let c = string::byte_at(hay, i);
            if c >= 48 && c <= 57 {
                return Option::Some(new Span(i, i + 1));
            }
            i = i + 1;
        }
        return Option::None;
    }

    pub fn is_prefix_of(Digit d, string hay) -> bool {
        return hay.len() > 0 && string::byte_at(hay, 0) >= 48 && string::byte_at(hay, 0) <= 57;
    }

    pub fn is_suffix_of(Digit d, string hay) -> bool {
        let n = hay.len();
        return n > 0 && string::byte_at(hay, n - 1) >= 48 && string::byte_at(hay, n - 1) <= 57;
    }
}

test("string patterns") {
    assert!("foobar".contains("oba"));
    assert!(!"foobar".contains("zz"));
    assert!("--verbose".starts_with("--"));
    assert!(!"verbose".starts_with("--"));
    assert!("main.hy".ends_with(".hy"));
    assert!(!"hy".ends_with("main.hy"));
    let at = "a=b=c".find("=") ?? new Span(-1, -1);
    assert!(at.start == 1 && at.end == 2);
    assert!("abc".find("z").is_none());
    assert!("a-b-c".find_all("-").len() == 2);
    assert!("aaa".find_all("aa").len() == 1);
}

test("split, split_once and replace") {
    let parts = "a,b,,c".split(",");
    assert!(parts.len() == 4);
    assert!(parts[2] == "" && parts[3] == "c");
    assert!(",a,".split(",").len() == 3);
    let (k, v) = "name=coil=lang".split_once("=") ?? ("", "");
    assert!(k == "name" && v == "coil=lang");
    assert!("plain".split_once("=").is_none());
    assert!("a-b-c".replace_first("-", "+") == "a+b-c");
    assert!("a-b-c".replace_all("-", "+") == "a+b+c");
    assert!("abc".replace_all("z", "+") == "abc");
}

test("empty matches step over whole characters") {
    let parts = "ab".split("");
    assert!(parts.len() == 4);
    assert!(parts[0] == "" && parts[1] == "a" && parts[2] == "b" && parts[3] == "");
    assert!("é!".replace_all("", "|") == "|é|!|");
    assert!("é".find_all("").len() == 2);
}

test("free functions keep their string-only behaviour") {
    assert!(contains("foobar", "oba"));
    let parts = split("ab", "") ?? Vec::new();
    assert!(parts.len() == 1);
}

test("a custom pattern") {
    let d = new Digit();
    assert!("v12".contains(d));
    assert!(!"vx".contains(d));
    assert!("1x".starts_with(d) && "x1".ends_with(d));
    assert!("a1b22c".split(d).len() == 4);
    assert!("a1b22c".replace_all(d, "#") == "a#b##c");
}

test("any Show type with an empty instance") {
    let v = new Version(1, 12);
    assert!(v.starts_with("1."));
    assert!(v.contains(new Digit()));
    assert!(v.split(".").len() == 2);
    assert!(v.replace_all(".", "-") == "1-12");
}
