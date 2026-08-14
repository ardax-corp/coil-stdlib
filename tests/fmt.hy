use fmt::{Buf};

test("buf push and pad") {
    let b = Buf::new();
    b.push_str("x");
    b.push_int(42);
    b.push_hex(255);
    assert(b.to_string() == "x42ff")?;
    b.pad_left(10, " ");
    assert(len(b.to_string()) == 10)?;
}
