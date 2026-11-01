use tests::assert;
use encoding::{encode, decode};
use string::{to_bytes, from_bytes};
use bytes::eq;

fn must_decode(string s) -> Vec<byte> {
    return match decode(s) {
        Result::Ok(v) => v,
        Result::Err(_) => panic "decode failed",
    };
}

fn decode_str(string s) -> string {
    return match from_bytes(must_decode(s)) {
        Result::Ok(v) => v,
        Result::Err(_) => panic "from_bytes failed",
    };
}

test("base64 encode") {
    let data = to_bytes("hi");
    let enc = encode(data);
    assert!(enc == "aGk=");
}

test("base64 roundtrip lengths") {
    assert!(encode(to_bytes("")) == "");
    assert!(encode(to_bytes("a")) == "YQ==");
    assert!(encode(to_bytes("hi")) == "aGk=");
    assert!(encode(to_bytes("abc")) == "YWJj");
    assert!(must_decode("").len() == 0);
    assert!(decode_str("YQ==") == "a");
    assert!(decode_str("aGk=") == "hi");
    assert!(decode_str("YWJj") == "abc");
    assert!(decode_str("YWJjZA==") == "abcd");
}

test("base64 decode unpadded partial quartet") {
    assert!(decode_str("YQ") == "a");
    assert!(decode_str("aGk") == "hi");
}

test("base64 decode whitespace and invalid") {
    assert!(decode_str("aG\nk=") == "hi");
    let err = match decode("!!!!") {
        Result::Ok(_) => "",
        Result::Err(msg) => msg,
    };
    assert!(err == "invalid base64");
}

test("base64 zero bytes roundtrip") {
    let raw: Vec<byte> = Vec::new();
    raw.push(0);
    raw.push(0);
    raw.push(0);
    raw.push(65);
    raw.push(0);
    let enc = encode(raw);
    assert!(enc == "AAAAQQA=");
    assert!(eq(must_decode(enc), raw));
}
