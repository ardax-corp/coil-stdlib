use fmt::{Buf};

test("buf push and pad") {
    let b = Buf::new();
    b.push_str("x");
    b.push_int(42);
    b.push_hex(255);
    assert(b.to_string() == "x42ff")?;
    b.pad_left(10, " ");
    assert(b.to_string() == "     x42ff")?;
}

test("buf pad right and noop") {
    let b = Buf::new();
    b.push_str("hi");
    b.pad_right(5, ".");
    assert(b.to_string() == "hi...")?;
    b.pad_right(3, ".");
    assert(b.to_string() == "hi...")?;
    let empty = Buf::new();
    assert(empty.to_string() == "")?;
}
