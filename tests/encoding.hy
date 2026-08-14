use encoding::{encode};
use string::{to_bytes};

test("base64 encode") {
    let data = to_bytes("hi");
    let enc = encode(data);
    assert(enc == "aGk=")?;
}
