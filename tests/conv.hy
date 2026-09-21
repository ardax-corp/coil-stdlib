use conv::{int_to_dec, parse_int, parse_float};

test("decimal integer format and parse") {
    assert(int_to_dec(0) == "0")?;
    assert(int_to_dec(42) == "42")?;
    assert(int_to_dec(-907) == "-907")?;
    // Two-slot `Result<int,string>` + `?` twice in one test drops the value;
    // match keeps the payload (same as tests/conv_extra.hy using one `?`).
    let a = match parse_int("123") {
        Result::Ok(v) => v,
        Result::Err(_) => panic "parse 123",
    };
    let b = match parse_int("+8") {
        Result::Ok(v) => v,
        Result::Err(_) => panic "parse +8",
    };
    let c = match parse_int("-45") {
        Result::Ok(v) => v,
        Result::Err(_) => panic "parse -45",
    };
    assert(a == 123)?;
    assert(b == 8)?;
    assert(c == -45)?;
}

test("invalid decimal integer") {
    let failed = match parse_int("12x") {
        Result::Ok(_) => false,
        Result::Err(_) => true,
    };
    assert(failed)?;
}

test("decimal float parse fraction") {
    assert(parse_float("12.5")? == 12.5)?;
}

test("decimal float parse leading dot") {
    assert(parse_float("-.25")? == 0.0 - 0.25)?;
}

test("decimal float parse positive exponent") {
    assert(parse_float("1.5e2")? == 150.0)?;
}

test("decimal float parse negative exponent") {
    let value = parse_float("2E-1")?;
    assert(value > 0.19)?;
    assert(value < 0.21)?;
}
