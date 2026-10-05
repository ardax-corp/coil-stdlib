use conv::{int_to_hex, int_to_bin, parse_int_radix, parse_int};
use bytes::{to_hex, from_hex, eq};
use string::{to_bytes};

test("int to hex bin") {
    assert(int_to_hex(255) == "ff")?;
    assert(int_to_bin(5) == "101")?;
    assert(int_to_hex(0 - 255) == "-ff")?;
    assert(int_to_bin(0 - 5) == "-101")?;
}

test("parse int trim and radix") {
    assert(parse_int("  42  ")? == 42)?;
    assert(parse_int_radix("ff", 16)? == 255)?;
    match parse_int_radix("7", 8) {
        Result::Ok(_) => panic "bad radix",
        Result::Err(_) => 0,
    };
    match parse_int("") {
        Result::Ok(_) => panic "empty",
        Result::Err(_) => 0,
    };
    match parse_int("+") {
        Result::Ok(_) => panic "plus only",
        Result::Err(_) => 0,
    };
}

test("bytes hex roundtrip") {
    let raw = to_bytes("ab");
    assert(to_hex(raw) == "6162")?;
    let back = from_hex("6162")?;
    assert(eq(back, raw))?;
    match from_hex("abc") {
        Result::Ok(_) => panic "odd len",
        Result::Err(_) => 0,
    };
    match from_hex("zz") {
        Result::Ok(_) => panic "invalid",
        Result::Err(_) => 0,
    };
}
