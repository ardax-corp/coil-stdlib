use conv::{int_to_hex, int_to_bin, parse_int_radix, parse_int};
use bytes::{to_hex, from_hex, eq};
use string::{to_bytes};

test("int to hex bin") {
    assert(int_to_hex(255) == "ff")?;
    assert(int_to_bin(5) == "101")?;
}

test("parse int trim and radix") {
    assert(parse_int("  42  ")? == 42)?;
    assert(parse_int_radix("ff", 16)? == 255)?;
}

test("bytes hex roundtrip") {
    let raw = to_bytes("ab");
    assert(to_hex(raw) == "6162")?;
    let back = from_hex("6162")?;
    assert(eq(back, raw))?;
}
