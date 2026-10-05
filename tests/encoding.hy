use encoding::{encode, decode};
use string::{to_bytes, from_bytes};
use bytes::{eq};

test("base64 encode") {
    let data = to_bytes("hi");
    let enc = encode(data);
    assert(enc == "aGk=")?;
}

test("base64 roundtrip lengths") {
    assert(encode(to_bytes("")) == "")?;
    assert(encode(to_bytes("a")) == "YQ==")?;
    assert(encode(to_bytes("hi")) == "aGk=")?;
    assert(encode(to_bytes("abc")) == "YWJj")?;

    let empty = match decode("") {
        Result::Ok(v) => v,
        Result::Err(_) => panic "decode empty",
    };
    assert(len(empty) == 0)?;

    let a = match decode("YQ==") {
        Result::Ok(v) => v,
        Result::Err(_) => panic "decode a",
    };
    let a_s = match from_bytes(a) {
        Result::Ok(s) => s,
        Result::Err(_) => panic "from_bytes a",
    };
    assert(a_s == "a")?;

    let hi = match decode("aGk=") {
        Result::Ok(v) => v,
        Result::Err(_) => panic "decode hi",
    };
    let hi_s = match from_bytes(hi) {
        Result::Ok(s) => s,
        Result::Err(_) => panic "from_bytes hi",
    };
    assert(hi_s == "hi")?;

    let abc = match decode("YWJj") {
        Result::Ok(v) => v,
        Result::Err(_) => panic "decode abc",
    };
    let abc_s = match from_bytes(abc) {
        Result::Ok(s) => s,
        Result::Err(_) => panic "from_bytes abc",
    };
    assert(abc_s == "abc")?;
}

test("base64 decode whitespace and invalid") {
    let hi = match decode("aG\nk=") {
        Result::Ok(v) => v,
        Result::Err(_) => panic "decode ws",
    };
    let hi_s = match from_bytes(hi) {
        Result::Ok(s) => s,
        Result::Err(_) => panic "from_bytes ws",
    };
    assert(hi_s == "hi")?;
    match decode("!!!!") {
        Result::Ok(_) => panic "expected invalid",
        Result::Err(msg) => assert(msg == "invalid base64")?,
    };
}

test("base64 null byte roundtrip") {
    let raw: Vec<byte> = Vec::new();
    raw.push(0);
    raw.push(0);
    raw.push(0);
    let enc = encode(raw);
    let back = match decode(enc) {
        Result::Ok(v) => v,
        Result::Err(_) => panic "decode nulls",
    };
    assert(eq(back, raw))?;
}
