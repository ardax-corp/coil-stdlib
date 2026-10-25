use tests::assert;
use text::{Text, from_codepoints};

test("chars splits at character boundaries, not bytes (#63)") {
    let s = "h\u{e9}llo";
    assert!(s.len() == 6);
    assert!(s.char_len() == 5);
    let cs = s.chars();
    assert!(cs.len() == 5 && cs[1] == "\u{e9}");
    assert!((s.char_at(1) ?? "") == "\u{e9}");
    assert!(s.char_at(5).is_none());
    assert!(s.char_at(-1).is_none());
}

test("codepoints decodes every UTF-8 length") {
    let cps = "a\u{e9}\u{416}\u{20ac}\u{1f600}".codepoints();
    assert!(cps.len() == 5);
    assert!(cps[0] == 97 && cps[1] == 233 && cps[2] == 1046 && cps[3] == 8364 && cps[4] == 128512);
    assert!(from_codepoints(cps) == "a\u{e9}\u{416}\u{20ac}\u{1f600}");
}

test("a byte index still reads one byte") {
    let s = "h\u{e9}llo";
    assert!(s[1] as int == 195);
}

test("case mapping covers Latin, Greek and Cyrillic") {
    assert!("Hello, WORLD".to_lower() == "hello, world");
    assert!("\u{c9}COLE \u{e0} \u{d1}".to_lower() == "\u{e9}cole \u{e0} \u{f1}");
    assert!("stra\u{df}e \u{e9}t\u{e9}".to_upper() == "STRA\u{df}E \u{c9}T\u{c9}");
    assert!(
        "\u{41f}\u{440}\u{438}\u{432}\u{435}\u{442}".to_upper() ==
        "\u{41f}\u{420}\u{418}\u{412}\u{415}\u{422}",
    );
    assert!(
        "\u{41c}\u{41e}\u{421}\u{41a}\u{412}\u{410} \u{401}".to_lower() ==
        "\u{43c}\u{43e}\u{441}\u{43a}\u{432}\u{430} \u{451}",
    );
    assert!(
        "\u{3b1}\u{3b2}\u{3b3} \u{3c9}\u{3c2}".to_upper() == "\u{391}\u{392}\u{393} \u{3a9}\u{3a3}",
    );
    assert!(
        "\u{394}\u{388}\u{39b}\u{3a4}\u{391}".to_lower() == "\u{3b4}\u{3ad}\u{3bb}\u{3c4}\u{3b1}",
    );
    assert!("\u{141}\u{f3}d\u{17a}".to_upper() == "\u{141}\u{d3}D\u{179}");
    assert!("\u{10c}\u{11b}".to_lower() == "\u{10d}\u{11b}");
}

test("case mapping leaves scripts without case alone") {
    assert!("\u{65e5}\u{672c} 42 \u{1f600}".to_upper() == "\u{65e5}\u{672c} 42 \u{1f600}");
}
